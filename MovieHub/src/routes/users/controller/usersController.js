import {  mssql ,getConnection} from '../../../db/db.js'; 
import bcrypt from 'bcrypt';
export const GetAllUsers = async (req, res) => {
    try {
        const pool = await getConnection();
        const result = await pool.request().query('SELECT * FROM Users');
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
        const result = await pool.request().query(`SELECT Id,Name,Email FROM Users WHERE id = ${userId}`);
        res.json(result.recordset[0]);
    }
    catch(err){
        console.log(err);
        res.json({error: 'Error al obtener el usuario'});
    }
}
export const login=async(req, res) => {
    const {email, password} = req.body;
    try {
        const pool = await getConnection();
        const result = await pool.request().query(`SELECT * FROM Users WHERE Email = '${email}'`);
        if (result.recordset.length > 0) {
            const user = result.recordset[0];
            const hashedPassword = user.Password;
            const isCorrectPass = await bcrypt.compare(password, hashedPassword);
            if (isCorrectPass) {
                res.json({ message: 'Login de usuario exitoso', user });
            } else {
                res.status(404).json({ message: 'Contraseña incorrecta' });
            }
        } else {
            res.status(404).json({ message: 'Usuario o contraseña incorrectos' });
        }
    } catch (err) {
        console.log(err);
        res.status(500).json({ error: 'Error al iniciar sesión el usuario' });
    }
}
export const UpdateUser=async (req, res) => {
    const userId = req.params.id;
    const {name, email, password} = req.body;
    const hashedPassword = bcrypt.hashSync(password, 10);
    try {
        const pool = await getConnection();
        const result = await pool.request()
        .input('UserId', mssql.int, userId)
        .input('NewName', mssql.NVarChar, name)
        .input('NewEmail', mssql.NVarChar, email)
        .input('NewPassword', mssql.NVarChar, hashedPassword)
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
    .input('UserId', mssql.int, userId)
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
        .input('Name', mssql.NVarChar, name)
        .input('Email', mssql.NVarChar, email)
        .input('Password', mssql.NVarChar, hashedPassword)
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
