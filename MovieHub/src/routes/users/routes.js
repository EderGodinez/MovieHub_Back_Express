import express from 'express';
import { GetAllUsers, GetById, UpdateUser, DeleteUserById, RegisterUser, login } from './controller/usersController.js';
const router = express.Router();
// GET /users
router.get('/', GetAllUsers);
// GET /users/:id
router.get('/:id',GetById);
//POST /users/login
router.post('/login', login);
// PUT /users/:id
router.put('/:id', UpdateUser);
// DELETE /users/:id
router.delete('/:id',DeleteUserById);
// POST /users/register
router.post('/register', RegisterUser);

export default router;