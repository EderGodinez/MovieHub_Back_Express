USE [master]
GO
/****** Object:  Database [MovieHub]    Script Date: 23/07/2024 10:30:25 p. m. ******/
CREATE DATABASE [MovieHub]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'MovieHub', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\MovieHub.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'MovieHub_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\MovieHub_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [MovieHub] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [MovieHub].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [MovieHub] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [MovieHub] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [MovieHub] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [MovieHub] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [MovieHub] SET ARITHABORT OFF 
GO
ALTER DATABASE [MovieHub] SET AUTO_CLOSE ON 
GO
ALTER DATABASE [MovieHub] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [MovieHub] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [MovieHub] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [MovieHub] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [MovieHub] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [MovieHub] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [MovieHub] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [MovieHub] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [MovieHub] SET  ENABLE_BROKER 
GO
ALTER DATABASE [MovieHub] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [MovieHub] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [MovieHub] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [MovieHub] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [MovieHub] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [MovieHub] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [MovieHub] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [MovieHub] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [MovieHub] SET  MULTI_USER 
GO
ALTER DATABASE [MovieHub] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [MovieHub] SET DB_CHAINING OFF 
GO
ALTER DATABASE [MovieHub] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [MovieHub] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [MovieHub] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [MovieHub] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
ALTER DATABASE [MovieHub] SET QUERY_STORE = ON
GO
ALTER DATABASE [MovieHub] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [MovieHub]
GO
/****** Object:  UserDefinedFunction [dbo].[GetAverageRateById]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetAverageRateById] (@MediaId INT)
RETURNS FLOAT
AS
BEGIN
    DECLARE @AverageRate FLOAT;

    SELECT @AverageRate = AVG(Rate)
    FROM Ratings
    WHERE MediaId = @MediaId;

    RETURN @AverageRate;
END;

GO
/****** Object:  UserDefinedFunction [dbo].[GetLastViewDate]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetLastViewDate](@UserId INT,@MediaId INT)
RETURNS SMALLDATETIME
AS 
BEGIN
	DECLARE @LastView SMALLDATETIME;
	SELECT TOP 1 @LastView=UA.ActionDate 
	FROM UserActions UA
	WHERE UA.TypeAction = 'V'
	AND (UA.MediaId = @MediaId AND UA.UserId=@UserId)
	ORDER BY UA.ActionDate DESC;
	IF @@ROWCOUNT = 0
    SET @LastView = NULL;

	RETURN @LastView;
END;


GO
/****** Object:  UserDefinedFunction [dbo].[GetLikesById]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--Obtener el Número de Likes para un Medio
--Descripción: Devuelve el número total de "Likes" que un medio ha recibido.
--Parámetro: MediaId
--Retorno: Número de Likes (entero).	
CREATE FUNCTION [dbo].[GetLikesById](@MediaId INT)
RETURNS INT
AS
BEGIN
  DECLARE @LikeCount INT;
  SELECT @LikeCount = COUNT(*) 
  FROM UserActions UA
  WHERE UA.TypeAction = 'L'
  AND UA.MediaId = @MediaId;
  RETURN @LikeCount;
END;

GO
/****** Object:  Table [dbo].[Media]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Media](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](50) NOT NULL,
	[OriginalTitle] [nvarchar](50) NOT NULL,
	[Overview] [varchar](max) NOT NULL,
	[ImagePath] [varchar](255) NOT NULL,
	[PosterImage] [varchar](255) NOT NULL,
	[TrailerLink] [varchar](255) NOT NULL,
	[WatchLink] [varchar](255) NOT NULL,
	[AddedDate] [smalldatetime] NOT NULL,
	[TypeMedia] [varchar](10) NOT NULL,
	[RelaseDate] [smalldatetime] NOT NULL,
	[AgeRate] [char](8) NULL,
	[IsActive] [bit] NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[UserActions]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserActions](
	[UserId] [int] NULL,
	[MediaId] [int] NULL,
	[TypeAction] [char](1) NOT NULL,
	[ActionDate] [smalldatetime] NOT NULL,
 CONSTRAINT [UC_UserAction] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[MediaId] ASC,
	[TypeAction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ratings]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ratings](
	[UserId] [int] NULL,
	[MediaId] [int] NULL,
	[Rate] [tinyint] NOT NULL,
	[RateDate] [smalldatetime] NOT NULL,
 CONSTRAINT [UC_UserMedia] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[MediaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetRecommendedMedia]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GetRecommendedMedia] (@UserId INT)
RETURNS TABLE
AS
RETURN
(
    --Obtener los medios que el usuario ha calificado con una alta puntuación
    WITH UserTopRatedMedia AS (
        SELECT MediaId
        FROM Ratings
        WHERE UserId = @UserId
        AND Rate >= 8 -- Ajusta este valor según tus criterios
    ),
    --Obtener los medios que el usuario ha visto
    UserSeenMedia AS (
        SELECT MediaId
        FROM UserActions
        WHERE UserId = @UserId
        AND TypeAction = 'V' 
    ),
 
    --Recomendar medios similares a los que el usuario ha calificado altamente o visto
    RecommendedMedia AS (
        SELECT DISTINCT m.Id AS MediaId
        FROM Media m
        INNER JOIN UserTopRatedMedia urtm ON m.Id <> urtm.MediaId -- Evita recomendar los medios que ya ha calificado
        INNER JOIN UserSeenMedia usm ON m.Id <> usm.MediaId -- Evita recomendar los medios que ya ha visto
        WHERE m.Id NOT IN (SELECT MediaId FROM Ratings WHERE UserId = @UserId)
    )
    SELECT MediaId
    FROM RecommendedMedia
);

GO
/****** Object:  Table [dbo].[Users]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Users](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](50) NOT NULL,
	[Password] [varchar](150) NOT NULL,
	[Email] [varchar](50) NOT NULL,
	[Role] [varchar](10) NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetUserActionsDetails]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Crear la función que devuelve las acciones de un usuario sobre un medio
CREATE FUNCTION [dbo].[GetUserActionsDetails] (@UserId INT, @MediaId INT)
RETURNS TABLE
AS
RETURN
(
    SELECT UA.ActionDate AS FechaDeAccion, 
           UA.TypeAction, 
           M.TypeMedia AS Tipo, 
           M.Title AS Medio, 
		   M.Overview as Description,
           M.AgeRate AS Publico, 
           M.ImagePath, 
           M.PosterImage
    FROM UserActions UA
    INNER JOIN Media M ON M.Id = UA.MediaId
    INNER JOIN Users U ON U.Id = UA.UserId
    WHERE UA.UserId = @UserId 
    AND (@MediaId IS NULL OR UA.MediaId = @MediaId)
);
GO
/****** Object:  Table [dbo].[Episode]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Episode](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Title] [varchar](255) NOT NULL,
	[Overview] [varchar](max) NOT NULL,
	[E_Num] [int] NOT NULL,
	[Duration] [time](7) NOT NULL,
	[ImagePath] [varchar](255) NOT NULL,
	[AddedDate] [smalldatetime] NOT NULL,
	[WatchLink] [varchar](255) NOT NULL,
	[RelaseDate] [smalldatetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[EpisodesList]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EpisodesList](
	[Seasonld] [int] NOT NULL,
	[Episodeld] [int] NOT NULL,
 CONSTRAINT [UK_Episode_Item] UNIQUE NONCLUSTERED 
(
	[Seasonld] ASC,
	[Episodeld] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Genders]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Genders](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GendersList]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GendersList](
	[MediaId] [int] NOT NULL,
	[GenderId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MediaAvailableIn]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MediaAvailableIn](
	[MediaId] [int] NOT NULL,
	[PlatformId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Movie]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Movie](
	[MediaId] [int] NOT NULL,
	[Duration] [time](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Platforms]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Platforms](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Name] [varchar](20) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY],
UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Season]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Season](
	[Seasonld] [int] IDENTITY(1,1) NOT NULL,
	[SerieId] [int] NOT NULL,
	[NumSeason] [tinyint] NOT NULL,
	[DateRelease] [smalldatetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Seasonld] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Serie]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Serie](
	[Serield] [int] IDENTITY(1,1) NOT NULL,
	[Mediald] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Serield] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[Media] ADD  DEFAULT ((1)) FOR [IsActive]
GO
ALTER TABLE [dbo].[Ratings] ADD  DEFAULT (getdate()) FOR [RateDate]
GO
ALTER TABLE [dbo].[UserActions] ADD  DEFAULT (getdate()) FOR [ActionDate]
GO
ALTER TABLE [dbo].[Users] ADD  DEFAULT ('user') FOR [Role]
GO
ALTER TABLE [dbo].[EpisodesList]  WITH CHECK ADD  CONSTRAINT [FK_EpisodesList_Episode] FOREIGN KEY([Episodeld])
REFERENCES [dbo].[Episode] ([Id])
GO
ALTER TABLE [dbo].[EpisodesList] CHECK CONSTRAINT [FK_EpisodesList_Episode]
GO
ALTER TABLE [dbo].[EpisodesList]  WITH CHECK ADD  CONSTRAINT [FK_EpisodesList_Season] FOREIGN KEY([Seasonld])
REFERENCES [dbo].[Season] ([Seasonld])
GO
ALTER TABLE [dbo].[EpisodesList] CHECK CONSTRAINT [FK_EpisodesList_Season]
GO
ALTER TABLE [dbo].[GendersList]  WITH CHECK ADD FOREIGN KEY([GenderId])
REFERENCES [dbo].[Genders] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[GendersList]  WITH CHECK ADD FOREIGN KEY([MediaId])
REFERENCES [dbo].[Media] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[MediaAvailableIn]  WITH CHECK ADD FOREIGN KEY([MediaId])
REFERENCES [dbo].[Media] ([Id])
GO
ALTER TABLE [dbo].[MediaAvailableIn]  WITH CHECK ADD FOREIGN KEY([PlatformId])
REFERENCES [dbo].[Platforms] ([Id])
GO
ALTER TABLE [dbo].[Movie]  WITH CHECK ADD FOREIGN KEY([MediaId])
REFERENCES [dbo].[Media] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Ratings]  WITH CHECK ADD FOREIGN KEY([MediaId])
REFERENCES [dbo].[Media] ([Id])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Ratings]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON UPDATE CASCADE
ON DELETE SET NULL
GO
ALTER TABLE [dbo].[Season]  WITH CHECK ADD  CONSTRAINT [FK_Serie_Season] FOREIGN KEY([SerieId])
REFERENCES [dbo].[Serie] ([Serield])
GO
ALTER TABLE [dbo].[Season] CHECK CONSTRAINT [FK_Serie_Season]
GO
ALTER TABLE [dbo].[Serie]  WITH CHECK ADD  CONSTRAINT [FK_Serie_Media] FOREIGN KEY([Mediald])
REFERENCES [dbo].[Media] ([Id])
GO
ALTER TABLE [dbo].[Serie] CHECK CONSTRAINT [FK_Serie_Media]
GO
ALTER TABLE [dbo].[UserActions]  WITH CHECK ADD FOREIGN KEY([MediaId])
REFERENCES [dbo].[Media] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[UserActions]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[Users] ([Id])
ON UPDATE CASCADE
ON DELETE CASCADE
GO
ALTER TABLE [dbo].[Media]  WITH CHECK ADD CHECK  (([AgeRate]='r' OR [AgeRate]='b15' OR [AgeRate]='b' OR [AgeRate]='a'))
GO
ALTER TABLE [dbo].[Media]  WITH CHECK ADD CHECK  (([TypeMedia]='series' OR [TypeMedia]='movie'))
GO
ALTER TABLE [dbo].[Ratings]  WITH CHECK ADD CHECK  (([Rate]>=(1) AND [Rate]<=(10)))
GO
ALTER TABLE [dbo].[UserActions]  WITH CHECK ADD CHECK  (([TypeAction]='V' OR [TypeAction]='H' OR [TypeAction]='L'))
GO
ALTER TABLE [dbo].[Users]  WITH CHECK ADD CHECK  (([Role]='admin' OR [Role]='user'))
GO
/****** Object:  StoredProcedure [dbo].[CreateNewUser]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[CreateNewUser]
    @Name NVARCHAR(100),
    @Email NVARCHAR(255),
    @Password NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        INSERT INTO Users (Name, Email, Password)
        VALUES (@Name, @Email, @Password);
    END TRY
    BEGIN CATCH
        RAISERROR('Error al crear el nuevo usuario', 16, 1);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteEpisode]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteEpisode]
(
    @Id INT
)
AS
BEGIN
    DELETE FROM Episode WHERE Id = @Id;
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteMediaById]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteMediaById](
    @MediaId INT
)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @MediaTitle VARCHAR(MAX);
    SELECT @MediaTitle = Title FROM Media WHERE Id = @MediaId;
    DELETE FROM Media WHERE Id = @MediaId;
    IF @@ROWCOUNT > 0
        SELECT 'Media "' + @MediaTitle + '" eliminado con éxito';
    ELSE
        SELECT 'Media con id ' + CAST(@MediaId AS VARCHAR(10)) + ' no existe';
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteUser]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DeleteUser]
    @UserId INT
AS
BEGIN
    BEGIN TRY
        DELETE FROM Users
        WHERE Id = @UserId;
        DELETE FROM UserActions
        WHERE UserId = @UserId;
        DELETE FROM Ratings
        WHERE UserId = @UserId;
    END TRY
    BEGIN CATCH
        RAISERROR('Error al eliminar el usuario', 16, 1);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[GetRecommendedMediaForUser]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetRecommendedMediaForUser]
    @UserId INT
AS
BEGIN
    BEGIN TRY
        SELECT MediaId
        FROM dbo.GetRecommendedMedia(@UserId);
    END TRY
    BEGIN CATCH
        RAISERROR('Error al obtener las recomendaciones de medios', 16, 1);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[InsertEpisode]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[InsertEpisode]
(
    @Title VARCHAR(255),
    @Overview VARCHAR(MAX),
    @E_Num INT,
    @Duration TIME,
    @ImagePath VARCHAR(255),
    @AddedDate SMALLDATETIME,
    @WatchLink VARCHAR(255),
    @RelaseDate SMALLDATETIME
)
AS
BEGIN
    INSERT INTO Episode
    (
        Title, Overview, E_Num, Duration, ImagePath, AddedDate, WatchLink, RelaseDate
    )
    VALUES
    (
        @Title, @Overview, @E_Num, @Duration, @ImagePath, @AddedDate, @WatchLink, @RelaseDate
    );
END;
GO
/****** Object:  StoredProcedure [dbo].[RegisterMovie]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RegisterMovie] (
    @Title VARCHAR(50) ,
    @OriginalTitle NVARCHAR(50),
    @Overview VARCHAR(MAX) ,
    @ImagePath VARCHAR(255) ,
    @PosterImage VARCHAR(255) ,
    @TrailerLink VARCHAR(255) ,
    @WatchLink VARCHAR(255) ,
    @AddedDate SMALLDATETIME ,
    @RelaseDate SMALLDATETIME ,
    @AgeRate CHAR(8),
    @Duration TIME 
)
AS
BEGIN
    INSERT INTO Media (
        Title,
        OriginalTitle,
        Overview,
        ImagePath,
        PosterImage,
        TrailerLink,
        WatchLink,
        AddedDate,
        TypeMedia,
        RelaseDate,
        AgeRate,
        IsActive
    )
    VALUES (
        @Title,
        @OriginalTitle,
        @Overview,
        @ImagePath,
        @PosterImage,
        @TrailerLink,
        @WatchLink,
        @AddedDate,
        'movie',
        @RelaseDate,
        @AgeRate,
        1 -- IsActive 
    );

    -- Obtener Id de media registrada
    DECLARE @MediaId INT;
    SET @MediaId = SCOPE_IDENTITY();
    INSERT INTO Movie (
        MediaId,
        Duration
    )
    VALUES (
        @MediaId,
        @Duration
    );
END;
GO
/****** Object:  StoredProcedure [dbo].[RegisterRating]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RegisterRating]
    @UserId INT,
    @MediaId INT,
    @Rate TINYINT,
    @RateDate SMALLDATETIME
AS
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM Ratings WHERE UserId = @UserId AND MediaId = @MediaId)
        BEGIN
            UPDATE Ratings
            SET Rate = @Rate, RateDate = @RateDate
            WHERE UserId = @UserId AND MediaId = @MediaId;
        END
        ELSE
        BEGIN
            INSERT INTO Ratings (UserId, MediaId, Rate, RateDate)
            VALUES (@UserId, @MediaId, @Rate, @RateDate);
        END
    END TRY
    BEGIN CATCH
        RAISERROR('Error al registrar la calificación', 16, 1);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[RegisterSerie]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RegisterSerie] (
    @Title VARCHAR(50) ,
    @OriginalTitle NVARCHAR(50),
    @Overview VARCHAR(MAX) ,
    @ImagePath VARCHAR(255) ,
    @PosterImage VARCHAR(255) ,
    @TrailerLink VARCHAR(255) ,
    @WatchLink VARCHAR(255) ,
    @AddedDate SMALLDATETIME ,
    @RelaseDate SMALLDATETIME ,
    @AgeRate CHAR(8),
    @Duration TIME ,
	@SerieId INT OUTPUT
)
AS
BEGIN
BEGIN TRANSACTION;
    INSERT INTO Media (
        Title,
        OriginalTitle,
        Overview,
        ImagePath,
        PosterImage,
        TrailerLink,
        WatchLink,
        AddedDate,
        TypeMedia,
        RelaseDate,
        AgeRate,
        IsActive
    )
    VALUES (
        @Title,
        @OriginalTitle,
        @Overview,
        @ImagePath,
        @PosterImage,
        @TrailerLink,
        @WatchLink,
        @AddedDate,
        'series',
        @RelaseDate,
        @AgeRate,
        1 -- IsActive 
    );

    -- Obtener Id de media registrada
    DECLARE @MediaId INT;
    SET @MediaId = SCOPE_IDENTITY();
    INSERT INTO Serie(
        Mediald
    )
    VALUES (
        @MediaId
    );
	SET @SerieId = SCOPE_IDENTITY();
	 COMMIT TRANSACTION;
END;
GO
/****** Object:  StoredProcedure [dbo].[RegisterUserAction]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[RegisterUserAction]
    @UserId INT,
    @MediaId INT,
    @TypeAction CHAR(1), -- L: Like, V: View, H: Hide
    @ActionDate SMALLDATETIME
AS
BEGIN
    BEGIN TRY
        INSERT INTO UserActions (UserId, MediaId, TypeAction, ActionDate)
        VALUES (@UserId, @MediaId, @TypeAction, @ActionDate);
    END TRY
    BEGIN CATCH
        RAISERROR('Error al registrar la acción de usuario', 16, 1);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateEpisode]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateEpisode]
(
    @Id INT,
    @Title VARCHAR(255),
    @Overview VARCHAR(MAX),
    @E_Num INT,
    @Duration TIME,
    @ImagePath VARCHAR(255),
    @WatchLink VARCHAR(255),
    @RelaseDate SMALLDATETIME
)
AS
BEGIN
    UPDATE Episode
    SET
        Title = @Title,
        Overview = @Overview,
        E_Num = @E_Num,
        Duration = @Duration,
        ImagePath = @ImagePath,
        WatchLink = @WatchLink,
        RelaseDate = @RelaseDate
    WHERE Id = @Id;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateMovie]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateMovie](
    @MediaId INT,
    @Title VARCHAR(50),
    @OriginalTitle NVARCHAR(50),
    @Overview VARCHAR(MAX),
    @ImagePath VARCHAR(255),
    @PosterImage VARCHAR(255),
    @TrailerLink VARCHAR(255),
    @WatchLink VARCHAR(255) ,
    @RelaseDate SMALLDATETIME,
    @AgeRate CHAR(8) ,
    @Duration TIME 
)
AS
BEGIN
--Actualizar datos de media
    UPDATE Media
    SET Title = @Title,
        OriginalTitle = @OriginalTitle,
        Overview = @Overview,
        ImagePath = @ImagePath,
        PosterImage = @PosterImage,
        TrailerLink = @TrailerLink,
        WatchLink = @WatchLink,
        RelaseDate = @RelaseDate,
        AgeRate = @AgeRate
    WHERE Id = @MediaId;
	--Actualizar datos de tabla Movie
    UPDATE Movie
    SET Duration = @Duration
    WHERE MediaId = @MediaId;
END;
GO
/****** Object:  StoredProcedure [dbo].[UpdateUserInfo]    Script Date: 23/07/2024 10:30:26 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[UpdateUserInfo]
    @UserId INT,
    @NewName NVARCHAR(100),
    @NewEmail NVARCHAR(255),
    @NewPassword NVARCHAR(255)
AS
BEGIN
    BEGIN TRY
        UPDATE Users
        SET Name = @NewName,
            Email = @NewEmail,
            Password = @NewPassword
        WHERE Id = @UserId;
    END TRY
    BEGIN CATCH
        RAISERROR('Error al actualizar la información del usuario', 16, 1);
    END CATCH
END;
GO
USE [master]
GO
ALTER DATABASE [MovieHub] SET  READ_WRITE 
GO
