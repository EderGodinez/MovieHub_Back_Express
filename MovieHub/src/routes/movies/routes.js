import express from 'express';

const router = express.Router();

// Define your movie routes here
router.get('/', (req, res) => {
    // Handle GE for all movies
    res.send('GET /movies');
});

router.get('/:id', (req, res) => {
    // Handle GE for a specific movie by ID
    res.send('GET /movies/:id');
});

router.post('/', (req, res) => {
    // Handle POS to create a new movie
    res.send('POST /movies');
});

router.patch('/:id', (req, res) => {
    // Handle PATC to update a movie by ID
    res.send('PATCH /movies/:id');
});

router.delete('/:id', (req, res) => {
    // Handle DELET to delete a movie by ID
    res.send('DELETE /movies/:id');
});

export default router;