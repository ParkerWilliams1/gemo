/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// Import Firebase Admin and Function
const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp();

exports.resetCategoryClicks = functions.pubsub
    .schedule("every 24 hours") // Runs every 24 hours
    .onRun(async (context) => {
      const db = admin.firestore();
      const categoriesRef = db.collection("categories");

      try {
        const snapshot = await categoriesRef.get();
        const batch = db.batch();

        snapshot.forEach((doc) => {
          batch.update(doc.ref, {clicks: 0}); // Reset clicks to 0
        });

        await batch.commit();
        console.log("Successfully reset category clicks to 0.");
      } catch (error) {
        console.error("Error resetting category clicks:", error);
      }
    });

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
