import express from 'express';
import { registerMovie,GetMovieById,UpdateMovie,DeleteMovieById,getAllMovies,getTrendingMovies } from './controller/MoviesController.js';
const router = express.Router();
// Define your movie routes here
router.get('/', getAllMovies);

router.get('/:id', GetMovieById);

router.post('/', registerMovie);

router.patch('/:id', UpdateMovie);

router.delete('/:id', DeleteMovieById);


export default router;