import mssql from 'mssql';
import dotenv from 'dotenv';
dotenv.config();
const config = {
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    server:  process.env.DB_SERVER,
    database: process.env.DB_DATABASE,
    options: {
        encrypt: true,
        enableArithAbort: true,
        trustServerCertificate: true,
    }
};
export async function getConnection() {
    try{
        return await mssql.connect(config);
    }
    catch(err){
        console.log(err);
    }
}
    
export { mssql };