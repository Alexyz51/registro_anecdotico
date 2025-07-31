const { setGlobalOptions } = require("firebase-functions");
const { onRequest } = require("firebase-functions/https");
const admin = require("firebase-admin");

// Inicializar Firebase Admin
admin.initializeApp();

// Opcional: limitar cantidad máxima de instancias simultáneas
setGlobalOptions({ maxInstances: 10 });

// Función HTTP para eliminar usuario y archivos de Storage
exports.deleteUserAndStorage = onRequest(async (req, res) => {
    if (req.method !== "POST") {
        return res.status(405).send("Método no permitido");
    }

    const uid = req.body.uid;

    if (!uid) {
        return res.status(400).send("Falta el UID del usuario");
    }

    try {
        // Eliminar usuario de Authentication
        await admin.auth().deleteUser(uid);
        console.log(`Usuario ${uid} eliminado de Authentication`);

        // Eliminar archivos del usuario en Storage
        const bucket = admin.storage().bucket();
        const userFilesPrefix = `${uid}/`;

        const [files] = await bucket.getFiles({ prefix: userFilesPrefix });

        if (files.length > 0) {
            await Promise.all(files.map((file) => file.delete()));
            console.log(`Archivos de ${uid} eliminados de Storage`);
        } else {
            console.log(`No se encontraron archivos para ${uid} en Storage`);
        }

        res.status(200).send(`Usuario ${uid} y sus archivos eliminados correctamente.`);
    } catch (error) {
        console.error("Error eliminando usuario y archivos:", error);
        res.status(500).send("Error eliminando usuario y archivos: " + error.message);
    }
});
