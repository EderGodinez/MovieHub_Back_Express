import {  mssql ,getConnection} from '../../../db/db.js'; 
export const getAllSeries = async (req, res) => {
    try {
        const pool = await getConnection();
        const result = await pool.request().query(`SELECT * FROM Media WHERE TypeMedia='series'`);
        res.json(result.recordset);
    } catch (err) {
        console.log(err);
        res.status(500).json({ error: 'Error fetching series' });
    }
};
// Obtener una serie por ID
export const getSeriesById = async (req, res) => {
    const seriesId = req.params.id;
    try {
        const pool = await getConnection();
        const result = await pool.request().query(`SELECT * FROM Media WHERE TypeMedia='series' AND Id = ${seriesId}`);
        const episodes = await pool.request()
            .input('SeriesId', mssql.Int, seriesId)
            .query(`
                SELECT E_Num,Episode.Title,Episode.Overview,Duration,Episode.ImagePath,Episode.AddedDate FROM Media 
                INNER JOIN Season ON Media.Id = Season.SerieId
                INNER JOIN EpisodesList ON Season.Seasonld = EpisodesList.Seasonld
                INNER JOIN Episode ON Episode.Id = EpisodesList.Episodeld
                WHERE TypeMedia='series' AND Media.Id = @SeriesId`);
        if (result.recordset.length > 0&&episodes.recordset.length>0) {
            res.json({ ...result.recordset[0], episodes: episodes.recordset });
        } else {
            res.status(404).json({ error: 'Serie no encontrada' });
        }
    } catch (err) {
        res.status(500).json({ error: 'Error durante la busqueda de serie' });
    }
};
// Crear una nueva serie
export const createSeries = async (req, res) => {
    const {title,originalTitle,overview,imagePath,posterImage,trailerLink,watchLink,addedDate,releaseDate,ageRate,duration} = req.body;
    try {
        const pool = await getConnection();
        await pool.request()
            .input('Title', mssql.VARCHAR, title)
            .input('OriginalTitle', mssql.NVARCHAR, originalTitle)
            .input('Overview', mssql.TEXT, overview)
            .input('ImagePath', mssql.VARCHAR, imagePath)
            .input('PosterImage', mssql.VARCHAR, posterImage)
            .input('TrailerLink', mssql.VARCHAR, trailerLink)
            .input('WatchLink', mssql.VARCHAR, watchLink)
            .input('AddedDate', mssql.SMALLDATETIME, addedDate)
            .input('ReleaseDate', mssql.SMALLDATETIME, releaseDate)
            .input('AgeRate', mssql.CHAR(8), ageRate)
            .input('Duration', mssql.TIME, duration)
            .execute('RegisterSerie');
        res.status(201).json({ message: 'Series creada exitosamente' });
    } catch (err) {
        res.status(500).json({ error: 'Error en la creacion de serie' });
    }
};
// Actualizar una serie por ID
export const updateSeries = async (req, res) => {
    const seriesId = req.params.id;
    const { title, originalTitle, overview, imagePath, posterImage, trailerLink, watchLink, addedDate, releaseDate, ageRate,IsActive } = req.body; 
    try {
        const pool = await getConnection();
        const result=await pool.request()
            .input('MediaId', mssql.Int, seriesId)
            .input('Title', mssql.NVarChar, title)
            .input('OriginalTitle', mssql.NVarChar, originalTitle)
            .input('Overview', mssql.Text, overview)
            .input('ImagePath', mssql.NVarChar, imagePath)
            .input('PosterImage', mssql.NVarChar, posterImage)
            .input('TrailerLink', mssql.NVarChar, trailerLink)
            .input('WatchLink', mssql.NVarChar, watchLink)
            .input('AddedDate', mssql.SmallDateTime, addedDate)
            .input('ReleaseDate', mssql.SmallDateTime, releaseDate)
            .input('AgeRate', mssql.Char(8), ageRate)
            .input('IsActive', mssql.bit, IsActive)
            .query(`UPDATE Media 
                SET Title = @Title, OriginalTitle = @OriginalTitle, Overview = @Overview, ImagePath = @ImagePath, PosterImage = @PosterImage,
                 TrailerLink = @TrailerLink, WatchLink = @WatchLink, AddedDate = @AddedDate, ReleaseDate = @ReleaseDate, AgeRate = @AgeRate, Duration = @Duration ,IsActive = @IsActive
                WHERE Id = @MediaId AND TypeMedia='series'`);
                if (result.rowsAffected[0] === 0) {
                    return res.status(404).json({ error: 'Serie no encontrada' });
                }
                else{
                    res.json({ message: 'Series updated successfully' });
                }
    } catch (err) {
        res.status(500).json({ error: 'Error updating series' });
    }
};
// Eliminar una serie por ID
export const deleteSeries = async (req, res) => {
    const seriesId = req.params.id;
    try {
        const pool = await getConnection();
        const result=await pool.request()
            .input('MediaId', mssql.Int, seriesId)
            .execute('DeleteMediaById');
            const responseMessage = result.recordset[0];
            if (responseMessage) {
                res.json({ message: responseMessage });
            } else {
                res.status(404).json({ error: 'Series not found' });
            }
    } catch (err) {
        res.status(500).json({ error: 'Error deleting series' });
    }
};
// Crear un episodio
export const createEpisode = async (req, res) => {
    const { title, overview, imagePath,e_Num, watchLink, addedDate, releaseDate,duration } = req.body; 
    try {
        const pool = await getConnection();
        const result=await pool.request()
            .input('Title', mssql.VarChar, title)
            .input('Overview', mssql.VarChar, overview)
            .input('E_Num', mssql.Int, e_Num)
            .input('Duration', mssql.Time, duration)
            .input('ImagePath', mssql.VarChar, imagePath)
            .input('AddedDate', mssql.SmallDateTime, addedDate)
            .input('WatchLink', mssql.VarChar, watchLink)
            .input('ReleaseDate', mssql.SmallDateTime, releaseDate)
           .execute('InsertEpisode');
           if (result.rowsAffected[0] > 0) {
            res.json({ message: 'Episodio insertado con éxito' });
        } else {
            res.status(400).json({ error: 'Error al insertar el episodio' });
        }
    } catch (err) {
        res.status(500).json({ error: 'Error creating episode' });
    }
};
// Eliminar un episodio por ID
export const deleteEpisode = async (req, res) => {
    const episodeId = req.params.id;
    try {
        const pool = await getConnection();
        await pool.request()
            .input('EpisodeId', mssql.Int, episodeId)
            .execute('DeleteEpisode');
            if (result.rowsAffected[0] > 0) {
                res.json({ message: 'Episodio eliminado con éxito' });
            } else {
                res.status(400).json({ error: 'Error al eliminar el episodio' });
            }
    } catch (err) {
        res.status(500).json({ error: 'Error deleting episode' });
    }
};
// Actualizar un episodio por ID
export const updateEpisode = async (req, res) => {
    const episodeId = req.params.id;
    const { title,overview,e_Num,duration,imagePath,watchLink,releaseDate } = req.body; 
    try {
        const pool = await getConnection();
        const result=await pool.request()
        .input('Id', mssql.Int, episodeId)
        .input('Title', mssql.VarChar, title)
        .input('Overview', mssql.VarChar, overview)
        .input('E_Num', mssql.Int, e_Num)
        .input('Duration', mssql.Time, duration)
        .input('ImagePath', mssql.VarChar, imagePath)
        .input('WatchLink', mssql.VarChar, watchLink)
        .input('ReleaseDate', mssql.SmallDateTime, releaseDate)
        .execute('UpdateEpisode');
        if (result.rowsAffected[0] === 0) {
            res.status(404).json({ error: 'Episodio no encontrado' });
        }
        else{
            res.json({ message: 'Episodio actualizado con éxito' });
        }
    } catch (err) {
        res.status(500).json({ error: 'Error updating episode' });
    }
};