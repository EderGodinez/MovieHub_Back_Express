import express from 'express';

const router = express.Router();

// GET /series
router.get('/', (req, res) => {
    // Logic to fetch all series from the database
    // Replace the following line with your implementation
    res.send('GET /series');
});

// GET /series/:id
router.get('/:id', (req , res) => {
    const seriesId = req.params.id;
    // Logic to fetch a specific series by ID from the database
    // Replace the following line with your implementation
    res.send(`GET /series/${seriesId}`);
});

// POST /series
router.post('/', (req, res) => {
    // Logic to create a new series in the database
    // Replace the following line with your implementation
    res.send('POST /series');
});

// PUT /series/:id
router.put('/:id', (req , res) => {
    const seriesId = req.params.id;
    // Logic to update a specific series by ID in the database
    // Replace the following line with your implementation
    res.send(`PUT /series/${seriesId}`);
});

// DELETE /series/:id
router.delete('/:id', (req , res) => {
    const seriesId = req.params.id;
    // Logic to delete a specific series by ID from the database
    // Replace the following line with your implementation
    res.send(`DELETE /series/${seriesId}`);
});

export default router;