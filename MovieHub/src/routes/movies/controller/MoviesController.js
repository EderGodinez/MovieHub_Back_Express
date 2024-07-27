
import {  mssql ,getConnection} from '../../../db/db.js'; 
export const getAllMovies=async (req, res) => {
    const pool = await getConnection();
    const result = await pool.request().
    query(`SELECT 
    ME.Id,
    ME.Title,
    ME.OriginalTitle,
    ME.Overview,
    ME.ImagePath,
    ME.PosterImage,
    ME.TrailerLink,
    ME.WatchLink,
    ME.AddedDate,
    ME.TypeMedia,
    ME.RelaseDate,
    ME.AgeRate,
    ME.IsActive,
    M.Duration,
    (SELECT STRING_AGG(G.Name, ', ') 
     FROM GendersList GL
     INNER JOIN Genders G ON G.Id = GL.GenderId
     WHERE GL.MediaId = ME.Id) AS Genders  
    FROM Media ME
	INNER JOIN Movie M ON ME.Id=M.MediaId 
    INNER JOIN GendersList GL ON GL.MediaId=ME.Id
    INNER JOIN Genders G ON G.Id=GL.GenderId
    WHERE ME.TypeMedia='movie'
    GROUP BY 
    ME.Id,
    ME.Title,
    ME.OriginalTitle,
    ME.Overview,
    ME.ImagePath,
    ME.PosterImage,
    ME.TrailerLink,
    ME.WatchLink,
    ME.AddedDate,
    ME.TypeMedia,
    ME.RelaseDate,
    ME.AgeRate,
    ME.IsActive,
    M.Duration
    ORDER BY ME.Id`);
    res.json(result.recordset);
}
export const registerMovie =async (req, res) => {
    const {title,originalTitle,overview,imagePath,posterImage,trailerLink,watchLink,addedDate,relaseDate,ageRate,duration} = req.body;
    try{
        const pool = await getConnection();
        const result = await pool.request()
            .input('Title', mssql.VarChar(50), title)
            .input('OriginalTitle', mssql.NVarChar(50), originalTitle)
            .input('Overview', mssql.VarChar(mssql.MAX), overview)
            .input('ImagePath', mssql.VarChar(255), imagePath)
            .input('PosterImage', mssql.VarChar(255), posterImage)
            .input('TrailerLink', mssql.VarChar(255), trailerLink)
            .input('WatchLink', mssql.VarChar(255), watchLink)
            .input('AddedDate', mssql.SmallDateTime, addedDate)
            .input('RelaseDate', mssql.SmallDateTime,relaseDate)
            .input('AgeRate', mssql.Char(8), ageRate)
            .input('Duration', mssql.Time, duration)
            .execute('RegisterMovie');

        if(result.rowsAffected[0] > 0){
            res.json({name, email,message: 'Pelicula registrada correctamente'});
        }
    }
    catch(err){
        console.log(err);
        res.json({error: 'Error al registrar la pelicula'});
    }
}

// Function to get a movie by ID
export const GetMovieById = async (req, res) => {
   try {
    const movieId = req.params.id;
    const pool = await getConnection();
    const result = await pool.request()
    .input('MovieId', mssql.Int, movieId).query(`
   SELECT 
    ME.Id,
    ME.Title,
    ME.OriginalTitle,
    ME.Overview,
    ME.ImagePath,
    ME.PosterImage,
    ME.TrailerLink,
    ME.WatchLink,
    ME.AddedDate,
    ME.TypeMedia,
    ME.RelaseDate,
    ME.AgeRate,
    ME.IsActive,
    M.Duration,
    (SELECT STRING_AGG(G.Name, ', ') 
     FROM GendersList GL
     INNER JOIN Genders G ON G.Id = GL.GenderId
     WHERE GL.MediaId = ME.Id) AS Genders
FROM Media ME
INNER JOIN Movie M ON ME.Id = M.MediaId
WHERE ME.Id = @MovieId AND ME.TypeMedia='movie'
    `)
    if (result.recordset.length === 0) {
        return res.status(404).json({ error: 'Pelicula no encontrada' });
    }
    else{
        const GendersArray=result.recordset[0].Genders.split(', ');
        result.recordset[0].Genders=GendersArray;
        res.json(result.recordset[0]);
    }
   } catch (error) {
       console.log(error);
        res.status(500).json({error: 'Error al obtener la pelicula' });
   }
}

// Function to update a movie
export const UpdateMovie =async (req, res) => {
   const MediaId = req.params.id;
    const {title,originalTitle,overview,imagePath,posterImage,trailerLink,watchLink,addedDate,relaseDate,ageRate,duration} = req.body;
    const pool = await getConnection();
    const result = await pool.request()
    .input('MediaId', mssql.int, MediaId)
    .input('Title', mssql.VarChar(50), title)
    .input('OriginalTitle', mssql.NVarChar(50), originalTitle)
    .input('Overview', mssql.VarChar(mssql.MAX), overview)
    .input('ImagePath', mssql.VarChar(255), imagePath)
    .input('PosterImage', mssql.VarChar(255), posterImage)
    .input('TrailerLink', mssql.VarChar(255), trailerLink)
    .input('WatchLink', mssql.VarChar(255), watchLink)
    .input('AddedDate', mssql.SmallDateTime, addedDate)
    .input('RelaseDate', mssql.SmallDateTime,relaseDate)
    .input('AgeRate', mssql.Char(8), ageRate)
    .input('Duration', mssql.Time, duration)
    .execute('UpdateMovie');
    if(result.rowsAffected[0] > 0){
        res.json({message: 'Pelicula actualizada correctamente'});
    }
    else{
        res.json({error: 'Error al actualizar la pelicula'});
    }

}

// Function to delete a movie
export const DeleteMovieById = async (req, res) => {
    const MediaId = req.params.id;
    const pool = await getConnection();
    const result = await pool.request()
    .input('MediaId', mssql.int, MediaId)
    .execute('DeleteMediaById');
    if(result.rowsAffected[0] > 0){
        res.json({message: 'Pelicula eliminada con exito'});
    }
    else{
        res.json({error: 'Error al eliminar la pelicula'});
    }
}

export const getTrendingMovies=async (req, res) => {
    try{
    const pool = await getConnection();
    const result = await pool.request().execute('GetTrendingMovies');
    res.json(result.recordset);
    }
    catch(err){
        console.log(err);
        res.json({error: 'Error al obtener las peliculas populares'});
    }
    
}

