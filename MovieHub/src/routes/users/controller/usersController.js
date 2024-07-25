import {  mssql ,getConnection} from '../../../db/db.js'; 
import bcrypt from 'bcrypt';
export const GetAllUsers = async (req, res) => {
    try {
        const pool = await getConnection();
        const result = await pool.request().query('SELECT * FROM users');
        res.json(result.recordset);
    } catch (error) {
        console.log(error);
        res.json({error: 'Error al obtener los usuarios'});
    }
}
export const GetById= async(req, res) => {
    const userId = req.params.id;
    try{
        const pool = await getConnection();
        const result = await pool.request().query(`SELECT Id,Name,Email FROM users WHERE id = ${userId}`);
        res.json(result.recordset[0]);
    }
    catch(err){
        console.log(err);
        res.json({error: 'Error al obtener el usuario'});
    }
}
export const login=async(req, res) => {
    const {email, password} = req.body;
    try{
        const pool = await getConnection();
        const HashPassword = bcrypt.hashSync(password, 10); 
        const result = await pool.request().query(`SELECT * FROM users WHERE email = '${email}' AND password = '${HashPassword}'`);
        if(result.recordset.length > 0){
            res.json({message: `Login de usuario exitoso`,user:result.recordset[0]});
        }
        else{
            res.status(404).send('Correo o contraseña incorrectos');
        }
    }
    catch(err){
        console.log(err);
        res.json({error: 'Error al iniciar sesion el usuario'});
    }
}
export const UpdateUser=async (req, res) => {
    const userId = req.params.id;
    const {name, email, password} = req.body;
    const hashedPassword = bcrypt.hashSync(password, 10);
    try {
        const pool = await getConnection();
        const result = await pool.request()
        .input('UserId', sql.int, userId)
        .input('NewName', sql.NVarChar, name)
        .input('NewEmail', sql.NVarChar, email)
        .input('NewPassword', sql.NVarChar, hashedPassword)
        .execute('UpdateUserInfo');
        if (result.rowsAffected[0] > 0) {
            res.json({userId, name, email, message: 'Usuario actualizado correctamente'});    
        }
    } catch (error) {
        console.log(error);
       res.json({error: 'Error al actualizar el usuario'});    
    }
}
export const DeleteUserById= async (req, res) => {
    const userId = req.params.id;
   try {
    const pool = await getConnection();
    const result = await pool.request()
    .input('UserId', sql.int, userId)
    .execute('DeleteUser');
    if(result.rowsAffected[0] > 0){
        res.json({userId, message: 'Usuario eliminado correctamente'});
    }
   } catch (error) {
    console.log(error);
    res.json({error: 'Error al eliminar el usuario'});
   }
}
export const RegisterUser= async(req, res) => {
    const {name, email, password} = req.body;
    const hashedPassword = await bcrypt.hash(password, 10);
    try{
        const pool = await getConnection();
        const result = await pool.request()
        .input('Name', sql.NVarChar, name)
        .input('Email', sql.NVarChar, email)
        .input('Password', sql.NVarChar, hashedPassword)
        .execute('CreateNewUser');

        if(result.rowsAffected[0] > 0){
            res.json({name, email,message: 'Usuario creado correctamente'});
        }
    }
    catch(err){
        console.log(err);
        res.json({error: 'Error al crear el usuario'});
    }
}
