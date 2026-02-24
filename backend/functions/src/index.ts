import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions';

admin.initializeApp();

const db = admin.firestore();
const entitlementCollection = 'entitlements';
const webhookSecret = process.env.REVENUECAT_WEBHOOK_SECRET ?? '';

type EntitlementStatus =
  | 'active'
  | 'grace'
  | 'expired'
  | 'billing_issue'
  | 'unknown';

type EntitlementType = 'free' | 'premium';

interface EntitlementDoc {
  appUserId: string;
  entitlement: EntitlementType;
  status: EntitlementStatus;
  expiresAt: number | null;
  verificationToken: string;
  updatedAt: number;
  source: 'server';
}

function nowUnix(): number {
  return Math.floor(Date.now() / 1000);
}

function createVerificationToken(appUserId: string): string {
  return Buffer.from(`${appUserId}:${nowUnix()}`).toString('base64url');
}

function toEntitlementFromEvent(eventType: string): {
  entitlement: EntitlementType;
  status: EntitlementStatus;
} {
  switch (eventType) {
    case 'INITIAL_PURCHASE':
    case 'RENEWAL':
    case 'UNCANCELLATION':
    case 'NON_RENEWING_PURCHASE':
      return { entitlement: 'premium', status: 'active' };
    case 'BILLING_ISSUE':
      return { entitlement: 'premium', status: 'billing_issue' };
    case 'CANCELLATION':
    case 'EXPIRATION':
    case 'REFUND':
      return { entitlement: 'free', status: 'expired' };
    default:
      return { entitlement: 'free', status: 'unknown' };
  }
}

exports.syncEntitlement = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const appUserId = String(req.body?.appUserId ?? '').trim();
  if (!appUserId) {
    res.status(400).json({ error: 'Missing appUserId' });
    return;
  }

  const docRef = db.collection(entitlementCollection).doc(appUserId);
  const snapshot = await docRef.get();

  if (!snapshot.exists) {
    const defaultDoc: EntitlementDoc = {
      appUserId,
      entitlement: 'free',
      status: 'unknown',
      expiresAt: null,
      verificationToken: '',
      updatedAt: nowUnix(),
      source: 'server',
    };
    await docRef.set(defaultDoc);
    res.status(200).json({
      entitlement: defaultDoc.entitlement,
      status: defaultDoc.status,
      expiresAt: defaultDoc.expiresAt,
      lastVerifiedAt: defaultDoc.updatedAt,
      verificationToken: defaultDoc.verificationToken,
      source: defaultDoc.source,
    });
    return;
  }

  const data = snapshot.data() as EntitlementDoc;
  res.status(200).json({
    entitlement: data.entitlement,
    status: data.status,
    expiresAt: data.expiresAt,
    lastVerifiedAt: data.updatedAt,
    verificationToken: data.verificationToken,
    source: data.source,
  });
});

exports.getEntitlement = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'GET') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const appUserId = String(req.query.appUserId ?? '').trim();
  if (!appUserId) {
    res.status(400).json({ error: 'Missing appUserId query param' });
    return;
  }

  const docRef = db.collection(entitlementCollection).doc(appUserId);
  const snapshot = await docRef.get();
  if (!snapshot.exists) {
    res.status(404).json({ error: 'Entitlement not found' });
    return;
  }

  const data = snapshot.data() as EntitlementDoc;
  res.status(200).json({
    entitlement: data.entitlement,
    status: data.status,
    expiresAt: data.expiresAt,
    lastVerifiedAt: data.updatedAt,
    verificationToken: data.verificationToken,
    source: data.source,
  });
});

exports.revenueCatWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method !== 'POST') {
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  const authorization = req.header('Authorization') ?? '';
  if (!webhookSecret || authorization !== `Bearer ${webhookSecret}`) {
    res.status(401).json({ error: 'Unauthorized' });
    return;
  }

  const event = req.body?.event;
  const appUserId = String(event?.app_user_id ?? '').trim();
  if (!appUserId) {
    res.status(400).json({ error: 'Missing event.app_user_id' });
    return;
  }

  const eventType = String(event?.type ?? '').trim();
  const mapping = toEntitlementFromEvent(eventType);
  const expirationAtMs = event?.expiration_at_ms;
  const expiresAt =
    typeof expirationAtMs === 'number' && expirationAtMs > 0
      ? Math.floor(expirationAtMs / 1000)
      : null;

  const doc: EntitlementDoc = {
    appUserId,
    entitlement: mapping.entitlement,
    status: mapping.status,
    expiresAt,
    verificationToken:
      mapping.entitlement === 'premium' ? createVerificationToken(appUserId) : '',
    updatedAt: nowUnix(),
    source: 'server',
  };

  await db.collection(entitlementCollection).doc(appUserId).set(doc, { merge: true });

  res.status(200).json({ ok: true });
});
