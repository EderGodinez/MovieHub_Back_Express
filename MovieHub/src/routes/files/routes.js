import express from 'express';
import { uploadFile,GetById,DeleteById,upload } from './controller/filesController.js';

const router = express.Router();


router.get('/:id',GetById);

router.post('/',upload.single('file'),uploadFile);

router.delete('/:id', DeleteById);

export default router;