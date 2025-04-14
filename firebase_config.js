import { getStorage, ref, uploadBytesResumable, getDownloadURL } from "firebase/storage";
import { getFirestore, doc, updateDoc } from "firebase/firestore";

const storage = getStorage();
const db = getFirestore();

async function uploadImage(file, categoryId) {
    const storageRef = ref(storage, `images/${file.name}`);
    const uploadTask = uploadBytesResumable(storageRef, file);

    uploadTask.on("state_changed",
        (snapshot) => { console.log(`Upload progress: ${(snapshot.bytesTransferred / snapshot.totalBytes) * 100}%`); },
        (error) => { console.error("Upload failed", error); },
        async () => {
            const downloadURL = await getDownloadURL(uploadTask.snapshot.ref);
            
            // Update Firestore document with the download URL
            const categoryRef = doc(db, "categories", categoryId);
            await updateDoc(categoryRef, { images: downloadURL });

            console.log("Image uploaded and URL stored successfully!");
        }
    );
}
