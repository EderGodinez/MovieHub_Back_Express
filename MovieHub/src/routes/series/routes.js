import express from 'express';
import { getAllSeries, getSeriesById, createSeries, updateSeries, deleteSeries, createEpisode, deleteEpisode, updateEpisode } from './controller/SeriesController.js';
const router = express.Router();
router.get('/', getAllSeries);
router.get('/:id', getSeriesById);
router.post('/', createSeries);
router.put('/:id', updateSeries);
router.delete('/:id', deleteSeries);
// Rutas para Episodios
router.post('/episode', createEpisode);
router.delete('/episode/:id', deleteEpisode);
router.patch('/episode/:id', updateEpisode);
export default router;