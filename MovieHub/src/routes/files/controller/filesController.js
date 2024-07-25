import multer from 'multer';
import path from 'path';
import { fileURLToPath } from 'url';
import { v4 as uuidv4 } from 'uuid';
import fs from 'fs';

// Convert the module URL to a file path
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Espacio de almacenamiento donde se guardarán los archivos
const storage = multer.diskStorage({
    destination: path.join(__dirname, '../../../../public'),
    filename: (req, file, cb) => {
        const uniqueid = uuidv4();
        const ext = path.extname(file.originalname);
        cb(null, uniqueid + ext);
    }
});

export const upload = multer({ storage: storage });

// Función de controlador para subir archivo
export const uploadFile = async (req, res) => {
    res.json({
        message: `Archivo subido correctamente`,
        filename: `${req.file.filename}`
    });
};

// Función de controlador para obtener archivo por nombre
export const GetById = async (req, res) => {
    const filePath = path.join(__dirname, '../../../../public', req.params.id);
    console.log(filePath);
    res.sendFile(filePath, (err) => {
        if (err) {
            res.status(404).json({ message: 'Archivo no encontrado' });
        }
    });
};

// Función de controlador para eliminar archivo por nombre
export const DeleteById = async (req, res) => {
    const filePath = path.join(__dirname, '../../../../public', req.params.id);
    fs.unlink(filePath, (err) => {
        if (err) {
            res.status(404).json({ message: 'Archivo no encontrado' });
        } else {
            res.json({ message: 'Archivo eliminado correctamente' });
        }
    });
};