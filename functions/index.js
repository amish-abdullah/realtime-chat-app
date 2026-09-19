const { onCall } = require("firebase-functions/v2/https");
const { RtcTokenBuilder, RtcRole } = require("agora-access-token");

// ==========================================
// AGORA CONFIG
// ==========================================

const APP_ID = "97af69cd879542bdba1cfc14f5772662";

// Yahan apna Agora Primary Certificate paste karo
const APP_CERTIFICATE = "5691745ff13b455284c445b2bae602ea";

// ==========================================
// GENERATE AGORA TOKEN
// ==========================================

exports.generateAgoraToken = onCall((request) => {
    const data = request.data;

    const channelName = data.channelName;

    if (!channelName) {
        throw new Error("channelName is required");
    }

    // Token 1 hour ke liye valid hoga
    const expirationTimeInSeconds = 3600;

    const currentTimestamp = Math.floor(Date.now() / 1000);

    const privilegeExpiredTs =
        currentTimestamp + expirationTimeInSeconds;

    // UID 0 ka matlab Agora automatically UID assign karega
    const uid = 0;

    const token = RtcTokenBuilder.buildTokenWithUid(
        APP_ID,
        APP_CERTIFICATE,
        channelName,
        uid,
        RtcRole.PUBLISHER,
        privilegeExpiredTs
    );

    console.log("Agora token generated");
    console.log("Channel:", channelName);

    return {
        token: token,
        channelName: channelName,
    };
});