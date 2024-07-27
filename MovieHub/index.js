import express from "express";
import dotenv from 'dotenv';
import cors from 'cors';
// Import modular routers
import userRouter from './src/routes/users/routes.js';
import seriesRouter from './src/routes/series/routes.js';
import moviesRouter from './src/routes/movies/routes.js';
import filesRoutes from './src/routes/files/routes.js';
// Initialize express
import {getTrendingMovies} from './src/routes/movies/controller/MoviesController.js';
dotenv.config();
const app = express();
app.use(express.json());
app.use(cors({
  origin:'*'
}))
app.use(express.urlencoded({ extended: true }));
app.use(express.static('public'));
const PORT = process.env.PORT;
// Attach modular routers to the Express app
app.use('/files', filesRoutes);
app.use('/users', userRouter);
app.use('/series', seriesRouter);
app.use('/movies', moviesRouter);
app.get('/trending',getTrendingMovies);
// Start the Express server
app.listen(PORT, async () => { 
  console.log("Server running at PORT: ", PORT);    
}).on("error", (error) => {
  // gracefully handle error
  throw new Error(error.message);
});