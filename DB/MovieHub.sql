USE [master]
GO
/****** Object:  Database [MovieHub]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetAverageRateById]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetLastViewDate]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  UserDefinedFunction [dbo].[GetLikesById]    Script Date: 28/07/2024 06:18:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
/****** Object:  Table [dbo].[Media]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  Table [dbo].[UserActions]    Script Date: 28/07/2024 06:18:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[UserActions](
	[UserId] [int] NULL,
	[MediaId] [int] NULL,
	[TypeAction] [char](1) NOT NULL,
	[ActionDate] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Ratings]    Script Date: 28/07/2024 06:18:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Ratings](
	[UserId] [int] NULL,
	[MediaId] [int] NULL,
	[Rate] [tinyint] NOT NULL,
	[RateDate] [smalldatetime] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetRecommendedMedia]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  Table [dbo].[Users]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[GetUserActionsDetails]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  Table [dbo].[Episode]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  Table [dbo].[EpisodesList]    Script Date: 28/07/2024 06:18:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[EpisodesList](
	[Seasonld] [int] NOT NULL,
	[Episodeld] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Genders]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GendersList]    Script Date: 28/07/2024 06:18:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GendersList](
	[MediaId] [int] NOT NULL,
	[GenderId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[MediaAvailibleIn]    Script Date: 28/07/2024 06:18:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[MediaAvailibleIn](
	[MediaId] [int] NOT NULL,
	[PlatformId] [int] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Movie]    Script Date: 28/07/2024 06:18:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Movie](
	[MediaId] [int] NOT NULL,
	[Duration] [time](7) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Platforms]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Season]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
SET IDENTITY_INSERT [dbo].[Episode] ON 

INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (1, N'Capítulo uno: La desaparición de Will Byers', N'Will Byers desaparece misteriosamente cuando vuelve a casa tras jugar diez largas horas con sus mejores amigos, mientras tanto una niña con asombrosas cualidades aparece en una cafetería de la localidad.', 1, CAST(N'00:42:00' AS Time), N'path/to/image1.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch1', CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (2, N'Capítulo dos: La loca de la calle Maple', N'Los chicos se topan con la niña, ella le enseña un tatuaje a Mike con el número 11, indicándole que ese es su nombre. Once reconoce a Will en una foto por lo que los chicos suponen que sabe cual es el paradero de su amigo.', 2, CAST(N'00:42:00' AS Time), N'path/to/image2.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch1', CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (3, N'Capítulo tres: Todo está bien', N'Nancy, cada vez más preocupada, busca a su mejor amiga Barb y descubre lo que Jonathan está tramando. Joyce está segura de que Will está comunicándose con ella mediante las luces de su casa.', 3, CAST(N'00:42:00' AS Time), N'path/to/image3.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch1', CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (4, N'Capítulo cuatro: El cuerpo', N'Joyce se rehusa a aceptar que Will está muerto y sigue intentando comunicarse con él. Mientras, los chicos ayudan a Once a cambiar de imagen para poder colarla en la sala de radio del Instituto. Nancy y Jonathan deciden aliarse.', 4, CAST(N'00:42:00' AS Time), N'path/to/image4.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch4', CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (5, N'Capítulo cinco: La pulga y el acróbata', N'Hopper entra al laboratorio. Nancy y Jonathan enfrentan a lo que se llevó a Will, y los chicos le preguntan al señor Clarke cómo viajar a otra dimensión.', 5, CAST(N'00:42:00' AS Time), N'path/to/image5.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch5', CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (6, N'Capítulo seis: El monstruo', N'Jonathan busca a Nancy en la oscuridad y Steve hace lo mismo. Hopper y Joyce descubren la verdad sobre los experimentos del laboratorio.', 6, CAST(N'00:42:00' AS Time), N'path/to/image6.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch6', CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (7, N'Capítulo siete: La bañera', N'Once intenta llegar hasta Will, y Lucas advierte sobre algo terrible que se avecina. Nancy y Jonathan le muestran a la policía lo que captó con su cámara.', 7, CAST(N'00:42:00' AS Time), N'path/to/image7.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch7', CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (8, N'Capítulo ocho: El otro lado', N'El doctor Brenner detiene a Hopper y Joyce para un interrogatorio. Los chicos esperan con Once en el gimnasio, mientras que Nancy y Jonathan se preparan para luchar.', 8, CAST(N'00:42:00' AS Time), N'path/to/image8.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch8', CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (9, N'Se acerca el invierno', N'Eddard Stark está dividido entre su familia y un viejo amigo cuando le piden que sirva al lado del Rey Robert Baratheon.', 1, CAST(N'00:52:00' AS Time), N'path/to/got1.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch1', CAST(N'2011-04-17T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (10, N'El camino real', N'Los Lannister conspiran para asegurar el silencio de Bran; Jon y Tyrion se dirigen al Muro; Ned enfrenta una crisis familiar en el camino a Desembarco del Rey.', 2, CAST(N'00:56:00' AS Time), N'path/to/got2.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch2', CAST(N'2011-04-24T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (11, N'Lord Snow', N'Jon impresiona a Tyrion en el Castillo Negro; Ned enfrenta su pasado y futuro en Desembarco del Rey.', 3, CAST(N'00:58:00' AS Time), N'path/to/got3.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch3', CAST(N'2011-05-01T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (12, N'Lisiados, bastardos y cosas rotas', N'Ned investiga la muerte de Arryn; Jon toma medidas para proteger a Sam; Tyrion se encuentra en el lugar equivocado.', 4, CAST(N'00:56:00' AS Time), N'path/to/got4.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch4', CAST(N'2011-05-08T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (13, N'El lobo y el león', N'Catelyn lleva a Tyrion a enfrentar a su hermana; el Rey Robert y Ned enfrentan amenazas desde dentro y fuera.', 5, CAST(N'00:55:00' AS Time), N'path/to/got5.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch5', CAST(N'2011-05-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (14, N'Una corona dorada', N'Viserys recibe el pago final por Daenerys; Ned hace un decreto controvertido; Tyrion confiesa sus crímenes.', 6, CAST(N'00:53:00' AS Time), N'path/to/got6.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch6', CAST(N'2011-05-22T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (15, N'Ganas o mueres', N'Ned confronta a Cersei sobre la muerte de Jon Arryn; Jon hace sus votos en la Guardia de la Noche; Drogo promete llevar a los Dothraki a Desembarco del Rey.', 7, CAST(N'00:58:00' AS Time), N'path/to/got7.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch7', CAST(N'2011-05-29T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (16, N'El final del punto', N'Los Lannister aprovechan su ventaja sobre los Stark; Robb reúne a los aliados del norte de su padre y se dirige al sur a la guerra.', 8, CAST(N'01:00:00' AS Time), N'path/to/got8.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch8', CAST(N'2011-06-05T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (17, N'Baelor', N'Ned toma una decisión fatídica; Robb captura a un prisionero valioso; Daenerys encuentra su gobierno puesto a prueba.', 9, CAST(N'00:57:00' AS Time), N'path/to/got9.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch9', CAST(N'2011-06-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (18, N'Fuego y sangre', N'Los Stark lidian con el destino de Ned; Jon toma medidas para probarse a sí mismo; Daenerys ve un nuevo futuro para su gente.', 10, CAST(N'00:53:00' AS Time), N'path/to/got10.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch10', CAST(N'2011-06-19T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (19, N'Piloto', N'La vida del profesor de química de secundaria Walter White se transforma repentinamente por un diagnóstico médico grave.', 1, CAST(N'00:58:00' AS Time), N'path/to/bb1.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch1', CAST(N'2008-01-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (20, N'El gato está en la bolsa...', N'Walt y Jesse intentan deshacerse de los dos cuerpos en la RV, lo que se vuelve cada vez más complicado.', 2, CAST(N'00:48:00' AS Time), N'path/to/bb2.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch2', CAST(N'2008-01-27T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (21, N'...Y la bolsa está en el río', N'Walter y Jesse limpian el desastre causado por su primer trato de drogas, pero luego enfrentan un nuevo problema.', 3, CAST(N'00:48:00' AS Time), N'path/to/bb3.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch3', CAST(N'2008-02-10T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (22, N'Hombre cáncer', N'El cuñado de Walter, el agente de la DEA, Hank, le advierte que los traficantes de drogas pueden ser un negocio peligroso.', 4, CAST(N'00:48:00' AS Time), N'path/to/bb4.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch4', CAST(N'2008-02-17T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (23, N'Materia gris', N'El orgullo y los celos de Walter se interponen cuando sus ricos amigos ofrecen pagar sus tratamientos contra el cáncer.', 5, CAST(N'00:48:00' AS Time), N'path/to/bb5.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch5', CAST(N'2008-02-24T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (24, N'Una mano loca de nada', N'El nuevo negocio de Walter le da la oportunidad de sentirse nuevamente en control.', 6, CAST(N'00:48:00' AS Time), N'path/to/bb6.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch6', CAST(N'2008-03-02T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (25, N'Un trato sin complicaciones', N'Walter se vuelve aún más atrevido en su vida criminal, mientras Jesse lucha con sus propios problemas morales.', 7, CAST(N'00:48:00' AS Time), N'path/to/bb7.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch7', CAST(N'2008-03-09T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (26, N'El principio del fin', N'Geralt de Rivia, un cazador de monstruos, lucha por encontrar su lugar en un mundo donde la gente a menudo es más malvada que las bestias.', 1, CAST(N'01:01:00' AS Time), N'path/to/witcher1.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch1', CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (27, N'Cuatro marcos', N'Geralt se enfrenta a una poderosa bruja mientras que Ciri busca ayuda en el misterioso bosque de Brokilon.', 2, CAST(N'01:00:00' AS Time), N'path/to/witcher2.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch2', CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (28, N'Luna traicionera', N'Yennefer de Vengerberg se somete a un duro entrenamiento en Aretuza, mientras Geralt toma un contrato con resultados inesperados.', 3, CAST(N'01:07:00' AS Time), N'path/to/witcher3.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch3', CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (29, N'Bancarrota', N'Geralt y Jaskier descubren el peligro que acecha en los bosques mientras Yennefer lucha por controlar su magia.', 4, CAST(N'00:59:00' AS Time), N'path/to/witcher4.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch4', CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (30, N'Deseos incontenibles', N'Geralt y Jaskier encuentran una lámpara mágica que concede deseos, pero cada deseo tiene un precio.', 5, CAST(N'00:59:00' AS Time), N'path/to/witcher5.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch5', CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (31, N'Especies raras', N'Geralt se enfrenta a un dragón dorado mientras Yennefer se reúne con viejos conocidos en una peligrosa cacería.', 6, CAST(N'00:59:00' AS Time), N'path/to/witcher6.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch6', CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (32, N'Antes de la caída', N'Las tensiones políticas aumentan en el reino de Cintra mientras Geralt sigue buscando su destino.', 7, CAST(N'00:47:00' AS Time), N'path/to/witcher7.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch7', CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (33, N'Mucho más', N'Las historias de Geralt, Yennefer y Ciri convergen mientras el destino de los tres se entrelaza en la batalla por el futuro del Continente.', 8, CAST(N'00:59:00' AS Time), N'path/to/witcher8.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch8', CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (34, N'Crueldad', N'Tanjiro Kamado, un joven trabajador, descubre que su familia ha sido atacada por demonios al regresar a casa. Su hermana Nezuko ha sobrevivido, pero ha sido transformada en un demonio.', 1, CAST(N'00:23:00' AS Time), N'path/to/episode1.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch1', CAST(N'2019-04-06T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (35, N'El instructor, Sakonji Urokodaki', N'Tanjiro y Nezuko buscan la ayuda del misterioso Sakonji Urokodaki para revertir la transformación de Nezuko. Durante el entrenamiento, Tanjiro enfrenta varios desafíos.', 2, CAST(N'00:23:00' AS Time), N'path/to/episode2.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch2', CAST(N'2019-04-13T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (36, N'Sabito y Makomo', N'Tanjiro continúa su duro entrenamiento con Sakonji y recibe la ayuda de dos espíritus que le enseñan sobre la Respiración del Agua. Se prepara para una prueba crucial.', 3, CAST(N'00:23:00' AS Time), N'path/to/episode3.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch3', CAST(N'2019-04-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (37, N'Selección final', N'Tanjiro participa en la Selección Final, una prueba en la que debe enfrentarse a demonios en un campo abierto para convertirse en un cazador de demonios.', 4, CAST(N'00:23:00' AS Time), N'path/to/episode4.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch4', CAST(N'2019-04-27T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (38, N'Tu acero', N'Tanjiro vence al demonio gigante en la Selección Final y elige el material para forjar su espada Nichirin. Regresa a Sakonji para prepararse para su próxima misión.', 5, CAST(N'00:23:00' AS Time), N'path/to/episode5.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch5', CAST(N'2019-05-04T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (39, N'Espadachín con demonio', N'Tanjiro recibe su espada Nichirin de color negro y parte con Nezuko en su primera misión para detener a un demonio que secuestra jóvenes.', 6, CAST(N'00:23:00' AS Time), N'path/to/episode6.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch6', CAST(N'2019-05-11T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (40, N'Muzan Kibutsuji', N'Tanjiro se enfrenta a un demonio poderoso con la ayuda de Nezuko. Descubre que el demonio está utilizando un pantano para camuflarse.', 7, CAST(N'00:23:00' AS Time), N'path/to/episode7.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch7', CAST(N'2019-05-18T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (41, N'Cautivador olor a sangre', N'Muzan Kibutsuji escapa y Tanjiro se encuentra en una situación complicada, recibiendo la ayuda de un desconocido mientras enfrenta a nuevos demonios.', 8, CAST(N'00:23:00' AS Time), N'path/to/episode8.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch8', CAST(N'2019-05-25T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (42, N'Demonios de temari y flechas', N'Tanjiro enfrenta a dos poderosos demonios, Yahaba y Susamaru, que atacan con habilidades únicas, poniendo a prueba sus habilidades de combate.', 9, CAST(N'00:23:00' AS Time), N'path/to/episode9.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch9', CAST(N'2019-06-01T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (43, N'Siempre juntos', N'Tanjiro sigue luchando contra los demonios y enfrenta un brutal contraataque, mientras intenta proteger a sus amigos y completar su misión.', 10, CAST(N'00:23:00' AS Time), N'path/to/episode10.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch10', CAST(N'2019-06-08T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (44, N'La casa de los tambores', N'Tanjiro se encuentra con un cazador de demonios cobarde que lo acompaña en la peligrosa casa de los tambores, enfrentando desafíos inesperados.', 11, CAST(N'00:23:00' AS Time), N'path/to/episode11.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch11', CAST(N'2019-06-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (45, N'El jabalí muestra sus colmillos mientras Zenitsu duerme', N'Tanjiro protege a los inocentes dentro de la casa endemoniada mientras Zenitsu enfrenta sus propios temores y demuestra su valor.', 12, CAST(N'00:23:00' AS Time), N'path/to/episode12.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch12', CAST(N'2019-06-22T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (46, N'Algo más importante que la vida', N'Tanjiro enfrenta al demonio de los tambores, con una batalla que revela las verdaderas motivaciones del enemigo y pone a prueba la determinación de nuestros héroes.', 13, CAST(N'00:23:00' AS Time), N'path/to/episode13.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch13', CAST(N'2019-06-29T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (47, N'La casa del blasón de glicinias', N'Tanjiro enfrenta a un nuevo cazador de demonios con habilidades únicas, mientras busca una forma de superar los desafíos en la casa de los glicinias.', 14, CAST(N'00:23:00' AS Time), N'path/to/episode14.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch14', CAST(N'2019-07-06T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (48, N'El monte Natagumo', N'Tanjiro y sus compañeros son enviados a una tenebrosa montaña donde encuentran a un cazador que les advierte sobre la peligrosa situación que enfrentarán.', 15, CAST(N'00:23:00' AS Time), N'path/to/episode15.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch15', CAST(N'2019-07-13T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (49, N'Que otro vaya al frente', N'Tanjiro e Inosuke enfrentan a cazadores de demonios controlados por hilos en el bosque, colaborando para sobrevivir en una situación crítica.', 16, CAST(N'00:23:00' AS Time), N'path/to/episode16.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch16', CAST(N'2019-07-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (50, N'Domina una única cosa', N'Zenitsu busca a sus compañeros en la montaña y enfrenta a una terrorífica araña. La batalla revela desafíos inesperados y la verdadera naturaleza de su enemigo.', 17, CAST(N'00:23:00' AS Time), N'path/to/episode17.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch17', CAST(N'2019-07-27T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (51, N'Lazos simulados', N'Tanjiro e Inosuke se enfrentan a poderosos demonios en el bosque, mientras luchan por sobrevivir y encontrar una solución a sus problemas.', 18, CAST(N'00:23:00' AS Time), N'path/to/episode18.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch18', CAST(N'2019-08-03T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (52, N'Dios del fuego', N'Tanjiro enfrenta a Rui, uno de los demonios más poderosos, en una batalla épica que revela su verdadero poder y las motivaciones del enemigo.', 19, CAST(N'00:23:00' AS Time), N'path/to/episode19.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch19', CAST(N'2019-08-10T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (53, N'Una familia unida a la fuerza', N'Tanjiro se da cuenta de que su enfrentamiento con Rui no ha terminado como esperaba, y enfrenta nuevos desafíos en su camino.', 20, CAST(N'00:23:00' AS Time), N'path/to/episode20.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch20', CAST(N'2019-08-17T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (54, N'Violando las normas', N'La aparición de dos Pilares pone a Tanjiro y Nezuko en una situación peligrosa, ya que los Pilares buscan castigar a Nezuko por ser un demonio.', 21, CAST(N'00:23:00' AS Time), N'path/to/episode21.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch21', CAST(N'2019-08-24T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (55, N'El patrón', N'Tanjiro enfrenta el juicio de los Pilares, quienes deben decidir su destino y el de Nezuko, mientras el patrón intercede en su favor.', 22, CAST(N'00:23:00' AS Time), N'path/to/episode22.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch22', CAST(N'2019-08-31T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (56, N'Reunión de los Pilares', N'Los Pilares y el Patrón finalizan el juicio de Tanjiro y Nezuko, tomando decisiones sobre su futuro y la lucha contra los demonios.', 23, CAST(N'00:23:00' AS Time), N'path/to/episode23.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch23', CAST(N'2019-09-07T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (57, N'Entrenamiento restaurador', N'Tanjiro y sus compañeros se recuperan de sus heridas y enfrentan el duro entrenamiento restaurador bajo la guía de Kocho.', 24, CAST(N'00:23:00' AS Time), N'path/to/episode24.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch24', CAST(N'2019-09-14T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (58, N'Kanao Tsuyuri, Tsuguko', N'Tanjiro continúa su entrenamiento para dominar la respiración de concentración completa mientras sus compañeros observan desde la distancia. Conoce a Kanao Tsuyuri, una cazadora de demonios experimentada y Tsuguko de Shinobu Kocho.', 25, CAST(N'00:23:00' AS Time), N'path/to/episode25.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch25', CAST(N'2019-09-21T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (59, N'Una nueva misión', N'Tanjiro y sus compañeros se preparan para una nueva misión después de recuperarse de sus heridas. Mientras tanto, Kibutsuji realiza una cruel purga en su organización para eliminar a los traidores.', 26, CAST(N'00:23:00' AS Time), N'path/to/episode26.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'link/to/watch26', CAST(N'2019-09-28T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (60, N'The Mandalorian', N'El Mandaloriano protege al Niño de los cazadores de recompensas.', 1, CAST(N'00:49:27' AS Time), N'ruta/a/la/imagen/episodio1.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.disneyplus.com/es-4s/series/the-mandalorian/temporada-1/episodio-1', CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (61, N'The Child', N'El Mandaloriano lleva al Niño a un nuevo planeta.', 2, CAST(N'00:52:15' AS Time), N'ruta/a/la/imagen/episodio2.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.disneyplus.com/es-4s/series/the-mandalorian/temporada-1/episodio-2', CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (62, N'The Sin', N'El Mandaloriano busca a un antiguo mentor.', 3, CAST(N'00:49:45' AS Time), N'ruta/a/la/imagen/episodio3.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.disneyplus.com/es-4s/series/the-mandalorian/temporada-1/episodio-3', CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (63, N'Sanctuary', N'El Mandaloriano intenta proteger al Niño de un nuevo peligro.', 4, CAST(N'00:52:32' AS Time), N'ruta/a/la/imagen/episodio4.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.disneyplus.com/es-4s/series/the mandalorian/temporada-1/episodio-4', CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (64, N'Gunslinger', N'El Mandaloriano se une a un cazarrecompensas veterano.', 5, CAST(N'00:49:28' AS Time), N'ruta/a/la/imagen/episodio5.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.disneyplus.com/es-4s/series/the-mandalorian/temporada-1/episodio-5', CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (65, N'The Prisoner', N'El Mandaloriano se enfrenta a las consecuencias de sus acciones.', 6, CAST(N'00:52:24' AS Time), N'ruta/a/la/imagen/episodio6.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.disneyplus.com/es-4s/series/the-mandalorian/temporada-1/episodio-6', CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (66, N'The Reckoning', N'El Mandaloriano busca redimirse.', 7, CAST(N'00:52:16' AS Time), N'ruta/a/la/imagen/episodio7.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.disneyplus.com/es-4s/series/the-mandalorian/temporada-1/episodio-7', CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (67, N'Redemption', N'El Mandaloriano debe tomar una difícil decisión.', 8, CAST(N'00:49:49' AS Time), N'ruta/a/la/imagen/episodio8.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.disneyplus.com/es-4s/series/the-mandalorian/temporada-1/episodio-8', CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (68, N'El Himno Nacional', N'El Primer Ministro de Inglaterra se enfrenta a un dilema impactante cuando la princesa Susannah, un miembro muy querido de la familia real, es secuestrada.', 1, CAST(N'00:45:00' AS Time), N'ruta/a/la/imagen/episodio1_blackmirror.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.plataforma_streaming/black_mirror/episodio1', CAST(N'2011-12-04T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (69, N'15 Millones de Méritos', N'En un futuro distópico, los ciudadanos generan energía a través de ejercicios físicos y pueden comprar mejoras estéticas.', 2, CAST(N'00:50:00' AS Time), N'ruta/a/imagen/episodio2_blackmirror.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.plataforma_streaming/black_mirror/episodio2', CAST(N'2011-12-04T00:00:00' AS SmallDateTime))
INSERT [dbo].[Episode] ([Id], [Title], [Overview], [E_Num], [Duration], [ImagePath], [AddedDate], [WatchLink], [RelaseDate]) VALUES (70, N'El Santo y los Pecadores', N'Una joven y problemática estrella de Hollywood hace lo imposible para escapar de los paparazzi.', 3, CAST(N'00:48:00' AS Time), N'ruta/a/imagen/episodio3_blackmirror.jpg', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'https://www.plataforma_streaming/black_mirror/episodio3', CAST(N'2011-12-04T00:00:00' AS SmallDateTime))
SET IDENTITY_INSERT [dbo].[Episode] OFF
GO
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (1, 1)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (1, 2)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (1, 3)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (1, 4)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (1, 5)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (1, 6)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (1, 7)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (1, 8)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 9)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 10)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 11)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 12)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 13)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 14)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 15)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 16)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 17)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (2, 18)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (3, 19)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (3, 20)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (3, 21)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (3, 22)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (3, 23)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (3, 24)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (3, 25)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (4, 26)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (4, 27)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (4, 28)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (4, 29)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (4, 30)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (4, 31)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (4, 32)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (4, 33)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 34)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 35)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 36)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 37)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 38)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 39)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 40)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 41)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 42)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 43)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 44)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 45)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 46)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 47)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 48)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 49)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 50)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 51)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 52)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 53)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 54)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 55)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 56)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 57)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 58)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (5, 59)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (6, 60)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (6, 61)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (6, 62)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (6, 63)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (6, 64)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (6, 65)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (6, 66)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (6, 67)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (7, 68)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (7, 69)
INSERT [dbo].[EpisodesList] ([Seasonld], [Episodeld]) VALUES (7, 70)
GO
SET IDENTITY_INSERT [dbo].[Genders] ON 

INSERT [dbo].[Genders] ([Id], [Name]) VALUES (1, N'Acción')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (12, N'Animación')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (13, N'Anime')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (30, N'Artes Marciales')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (2, N'Aventura')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (15, N'Bélico')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (21, N'Biografía')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (10, N'Ciencia Ficción')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (29, N'Cine de Autor')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (24, N'Cine Negro')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (3, N'Comedia')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (16, N'Crimen')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (19, N'Deportivo')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (11, N'Documental')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (4, N'Drama')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (26, N'Experimental')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (20, N'Familiar')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (5, N'Fantasía')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (18, N'Histórico')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (27, N'Independiente')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (7, N'Misterio')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (28, N'Mudo')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (14, N'Musical')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (25, N'Película de Culto')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (8, N'Romance')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (23, N'Superhéroes')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (9, N'Suspenso')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (6, N'Terror')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (22, N'Thriller Psicológico')
INSERT [dbo].[Genders] ([Id], [Name]) VALUES (17, N'Western')
SET IDENTITY_INSERT [dbo].[Genders] OFF
GO
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (1, 4)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (1, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (1, 7)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (1, 9)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (2, 4)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (2, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (2, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (3, 4)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (3, 16)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (3, 9)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (4, 4)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (4, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (4, 7)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (4, 18)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (5, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (5, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (5, 13)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (6, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (6, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (6, 10)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (7, 6)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (7, 10)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (7, 13)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (7, 4)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (8, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (8, 2)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (8, 10)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (9, 12)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (9, 20)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (9, 2)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (9, 3)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (10, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (10, 2)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (10, 10)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (11, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (11, 16)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (11, 9)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (11, 3)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (12, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (12, 16)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (12, 9)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (13, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (13, 2)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (13, 10)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (14, 7)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (14, 9)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (14, 10)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (15, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (15, 4)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (16, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (16, 3)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (17, 9)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (17, 6)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (17, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (17, 7)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (18, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (18, 4)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (18, 15)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (19, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (19, 3)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (19, 19)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (19, 12)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (20, 4)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (21, 12)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (1, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (1, 19)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (1, 3)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (21, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (22, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (22, 6)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (22, 8)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (23, 3)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (23, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (23, 19)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (24, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (24, 16)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (24, 3)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (24, 9)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (25, 5)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (25, 2)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (25, 19)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (26, 1)
INSERT [dbo].[GendersList] ([MediaId], [GenderId]) VALUES (27, 6)
GO
SET IDENTITY_INSERT [dbo].[Media] ON 

INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (1, N'Stranger Things', N'Stranger Things', N'Un grupo de amigos en un pequeño pueblo se enfrenta a una serie de eventos paranormales que alteran sus vidas.', N'http://localhost:3000/files/7d7981f4-5431-4020-bafb-2f556ce57057.webp', N'http://localhost:3000/files/e6069743-9fd2-43b2-ba82-f81f4f5526b4.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'series', CAST(N'2016-07-15T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (2, N'Game of Thrones', N'Game of Thrones', N'En un mundo de fantasía, varias familias nobles luchan por el control del Trono de Hierro mientras enfrentan amenazas internas y externas.', N'http://localhost:3000/files/6fef8ad3-6b60-41ad-9450-b7456db65475.webp', N'http://localhost:3000/files/b6e0e993-6446-4d0c-9a62-eb020e0135ab.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'series', CAST(N'2011-04-17T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (3, N'Breaking Bad', N'Breaking Bad', N'Un profesor de química convertido en fabricante de metanfetaminas enfrenta desafíos morales y legales mientras se adentra en el mundo del crimen.', N'http://localhost:3000/files/3c4ceff9-3772-437c-be30-7b339ceefd0a.jpg', N'http://localhost:3000/files/77c5069d-ed1f-4918-a3f9-dcb5edc26265.webp', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'series', CAST(N'2008-01-20T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (4, N'The Witcher', N'The Witcher', N'Geralt de Rivia, un cazador de monstruos en un mundo de fantasía, lucha por encontrar su lugar en un universo caótico y lleno de criaturas malignas.', N'http://localhost:3000/files/5e3b1953-6bb0-48b0-9626-a0428c4268e9.jpg', N'http://localhost:3000/files/5076f6c1-d8a2-416b-b43f-12d6c3527030.webp', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'series', CAST(N'2019-12-20T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (5, N'Kimetsu no Yaiba', N'Kimetsu no Yaiba', N'Tanjiro Kamado, un joven cazador de demonios, lucha por proteger a su hermana demoníaca y vengar a su familia asesinada por demonios.', N'http://localhost:3000/files/ab2e81fa-8ee8-48e4-b2b6-a18ecac04383.webp', N'http://localhost:3000/files/e12b5bd6-649c-4f49-af04-3efd61d27026.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'series', CAST(N'2019-04-06T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (6, N'The Mandalorian', N'The Mandalorian', N'Una serie de televisión de acción y aventuras de ciencia ficción de los Estados Unidos creada por Jon Favreau para la plataforma de streaming Disney+.', N'http://localhost:3000/files/4e2f84e5-c271-40f7-a16f-0fe746f87e1b.jpg', N'http://localhost:3000/files/cc0f7829-deed-4812-8fad-ee29fc8cbd1a.jpg', N'https://www.youtube.com/watch?v=aN6zI3-PUeE', N'https://www.disneyplus.com/es-4s/series/the-mandalorian', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'series', CAST(N'2019-11-12T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (7, N'Black Mirror', N'Black Mirror', N'Una serie de televisión británica de ciencia ficción antológica creada por Charlie Brooker. Cada episodio es una historia independiente que explora temas relacionados con la tecnología y la sociedad.', N'http://localhost:3000/files/2ff0b0fd-d8be-4967-9457-8c7c20634da4.webp', N'http://localhost:3000/files/5c9fdba5-4314-433b-8412-ee3d9bf058b5.webp', N'https://www.youtube.com/watch?v=trailer_black_mirror', N'https://www.plataforma_streaming/black_mirror', CAST(N'2024-07-26T21:11:00' AS SmallDateTime), N'series', CAST(N'2011-12-04T00:00:00' AS SmallDateTime), N'b15     ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (8, N'Furiosa: De la Saga Mad Max', N'Furiosa: A Mad Max Saga', N'Mientras el mundo se derrumba, la joven Furiosa es secuestrada del Lugar Verde de Muchas Madres y cae en manos de una Horda de Motociclistas liderada por el Señor de la Guerra Dementus. Recorriendo la tierra baldía llega a la Ciudadela, presidida por Inmortan Joe. Mientras los dos tiranos luchan por el dominio de la zona, Furiosa deberá sobrevivir a muchas pruebas buscando volver a casa', N'http://localhost:3000/files/46ad059b-1dfa-443d-89ad-4fcdd38b5e72.jpg', N'http://localhost:3000/files/7d5c5665-e765-4608-ac93-7321be9a575b.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-05-22T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (9, N'IntensaMente 2', N'Inside Out 2', N'Una aventura completamente nueva dentro de la cabeza adolescente de Riley que presenta un nuevo conjunto de emociones.', N'http://localhost:3000/files/27889d78-eff7-4f7b-ae91-c6ac46ab9188.jpg', N'http://localhost:3000/files/7788b1cd-c0f4-4714-91e0-c65d237485df.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-06-11T00:00:00' AS SmallDateTime), N'a       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (10, N'El planeta de los simios: Nuevo reino', N'Kingdom of the Planet of the Apes', N'300 años después del reinado de César, un nuevo líder tiránico construye su imperio esclavizando a otros clanes de primates, un joven simio llamado Noa emprende un viaje desgarrador que lo hará cuestionar todo lo que sabía sobre el pasado y tomar decisiones que definirán el futuro tanto de simios como humanos.', N'http://localhost:3000/files/db41114e-5146-4365-b06c-fafc9e6a89ea.jpg', N'http://localhost:3000/files/50b99938-5bb1-4bcd-987b-711f2fd7dee2.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-05-08T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (11, N'Bad Boys: Hasta la muerte', N'Bad Boys: Ride or Die', N'Tras escuchar falsas acusaciones sobre su excapitán y mentor Mike y Marcus deciden investigar el asunto incluso volverse los más buscados de ser necesarios', N'http://localhost:3000/files/330b868d-1c20-48f0-a502-630986a3c5fd.jpg', N'http://localhost:3000/files/826df13e-8436-4bd0-aa11-b967dce0837a.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-06-05T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (12, N'Detonantes', N'Trigger Warning', N'Una agente de las fuerzas especiales desentraña una peligrosa conspiración cuando vuelve a casa en busca de respuestas sobre la muerte de su padre.', N'http://localhost:3000/files/e2122267-37c8-4fee-84fe-34e9086701f8.jpg', N'http://localhost:3000/files/4177fde6-8cac-48a4-9754-79fcc49df7e2.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-06-20T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (13, N'Godzilla y Kong: El nuevo imperio', N'Godzilla x Kong: The New Empire', N'Una aventura cinematográfica completamente nueva, que enfrentará al todopoderoso Kong y al temible Godzilla contra una colosal amenaza desconocida escondida dentro de nuestro mundo. La nueva y épica película profundizará en las historias de estos titanes, sus orígenes y los misterios de Isla Calavera y más allá, mientras descubre la batalla mítica que ayudó a forjar a estos seres extraordinarios y los unió a la humanidad para siempre.', N'http://localhost:3000/files/6618f017-66e0-493e-ac95-76176b6c021a.jpg', N'http://localhost:3000/files/df145540-0c75-4d66-8ab8-892c8c7a91d1.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-03-27T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (14, N'Un lugar en silencio: Día uno', N'A Quiet Place: Day One', N'Mientras la ciudad de Nueva York es invadida por criaturas alienígenas que cazan mediante el sonido, una mujer llamada Sammy lucha por sobrevivir.', N'http://localhost:3000/files/4cda70e3-5817-42c2-8589-165fd1205366.jpg', N'http://localhost:3000/files/722a2a4b-8df7-4df8-b0c8-f4645929007c.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-06-26T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (15, N'MR-9: Mision Mortal', N'MR-9: Do or Die', N'Masud Rana es un agente secreto con el nombre en clave MR-9 de la Agencia de Contrainteligencia de Bangladesh, que forma equipo con un agente de la CIA para acabar con una organización criminal internacional dirigida por un despiadado hombre de negocios.', N'http://localhost:3000/files/bb8810a0-b51a-4b49-999c-e57a2f165de4.jpg', N'http://localhost:3000/files/a87a448d-3f44-4ac2-8c44-d9da3cd9353f.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2023-08-25T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (16, N'Los Infalibles', N'Les Infaillibles', N'Cuando un grupo de ladrones provoca el caos en París y ridiculiza a la policía, el Ministro del Interior busca sangre nueva al frente de la investigación: Alia es de Marsella, temperamental e incontrolable, mientras que Hugo es parisino, meticuloso y el primero de su clase. En resumen, tienen todas las razones para odiarse. ¿Una alianza forzada o quizás algo más surgirá entre ellos?', N'http://localhost:3000/files/f56164c9-18de-4c53-b516-d818c2fa716b.jpg', N'http://localhost:3000/files/a41d0400-087c-4517-b053-4a288b075acf.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-06-20T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (17, N'En las Profundidades del Sena', N'Sous la Seine', N'Para salvar París de un baño de sangre internacional, una científica en duelo se ve obligada a enfrentarse a su trágico pasado cuando un tiburón gigante aparece en el Sena.', N'http://localhost:3000/files/181ce53d-dd50-46f6-aa85-c7057dc2090a.jpg', N'http://localhost:3000/files/88cd5c9c-a917-4f2d-ba6f-40ad5a52067b.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-06-05T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (18, N'Guerra Civil', N'Civil War', N'En un futuro cercano, un grupo de periodistas de guerra intenta sobrevivir mientras informan la verdad mientras Estados Unidos se encuentra al borde de una guerra civil.', N'http://localhost:3000/files/745e6935-e219-4246-94e4-b686b3bac441.jpg', N'http://localhost:3000/files/08103611-2825-4247-9e7c-aad494473395.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-04-10T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (19, N'Mi villano favorito 4', N'Despicable Me 4', N'Gru y Lucy dan a luz a Gru Jr. y ahi Gru, con su hijo y una aprendiz robaran algo para detener a los nuevos villanos de turno.', N'http://localhost:3000/files/ccf9fec7-f44c-425f-b344-9611430ffd11.jpg', N'http://localhost:3000/files/d16e3e46-496d-4c07-b174-b22ea0d9c7dd.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-06-20T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (20, N'Kung Fu Panda 4', N'Kung Fu Panda 4', N'Po se está preparando para convertirse en el líder espiritual de su Valle de la Paz, pero también necesita a alguien que ocupe su lugar como Guerrero Dragón. Como tal, entrenará a un nuevo practicante de kung fu para el lugar y se encontrará con un villano llamado Camaleón que evoca villanos del pasado.', N'http://localhost:3000/files/f6937fcf-ec7e-43e8-81f7-6e46a0467d0f.jpg', N'http://localhost:3000/files/3d09e2a9-3fa7-4ff9-b417-91d560848cf8.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-03-02T00:00:00' AS SmallDateTime), N'a       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (21, N'Observados', N'The Watchers', N'Mina, la artista de 28 años, queda varada en un extenso bosque virgen en el oeste de Irlanda. Al encontrar refugio, sin saberlo, queda atrapada junto a tres extraños que son observados y acechados por criaturas misteriosas cada noche.', N'http://localhost:3000/files/db18714a-cd5b-4435-aca3-4fb207d76bb5.jpg', N'http://localhost:3000/files/a8dfd276-ab3f-4a9e-86c8-27badb2463e9.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-06-06T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (22, N'Amigos imaginarios', N'IF', N'Una joven descubre la capacidad de ver a los amigos imaginarios de las personas que han sido abandonados por los niños a los que ayudaron.', N'http://localhost:3000/files/5890932c-f52e-4fc7-9344-c336f23641ed.jpg', N'http://localhost:3000/files/a6b55b5b-f6df-4ab0-907a-0432db0b64d8.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-05-08T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (23, N'Fuerza Bruta: Sin Salida', N'???? 3', N'Secuela de la taquilera película de acción coreana The Roundup. Siete años después de la redada en Vietnam, Ma Seok-do se une a un nuevo escuadrón para investigar un asesinato. No tardará en indagar más cuando descubre que el caso tiene que ver con una droga sintética y una banda de matones.', N'http://localhost:3000/files/4d0e8339-8d4d-45d6-950f-21d40b5e6bee.jpg', N'http://localhost:3000/files/ab7259cd-7959-482c-ad0c-df8127c542d0.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2023-05-31T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (24, N'La Academia del Sr. Kleks', N'Akademia Pana Kleksa', N'Para dar con su padre, una chica que aparenta normalidad acepta la invitación de asistir a una universidad mágica dirigida por un excéntrico maestro, el Sr. Kleks.', N'http://localhost:3000/files/6c44215a-6d83-4cb3-9b99-f1d3fec70550.jpg', N'http://localhost:3000/files/33d7fb00-1a67-4a49-8dfd-5d6fe0c7e94f.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-01-05T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (25, N'The Last Kumite', N'The Last Kumite', N'Un último kumite, una batalla final - por la vida de su hija.', N'http://localhost:3000/files/dbab8efe-e7de-4268-93eb-13d7d5a1c917.jpg', N'http://localhost:3000/files/a9fa983f-5a3e-4a87-ad34-44ce269c4976.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-05-09T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (26, N'Tarot de la muerte', N'Tarot', N'Cuando un grupo de amigos viola imprudentemente la regla sagrada de las lecturas de Tarot -nunca usar la baraja de otra persona-, desatan sin saberlo un mal innombrable atrapado en las cartas malditas. Uno a uno, se enfrentan cara a cara con el destino y terminan en una carrera contra la muerte para escapar del futuro predicho en sus lecturas.', N'http://localhost:3000/files/e78977a0-35b4-4374-b493-897a63ff714e.jpg', N'http://localhost:3000/files/9c9a1d14-e7ba-4ea4-bfab-af0f84622f8c.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-05-01T00:00:00' AS SmallDateTime), N'b       ', 1)
INSERT [dbo].[Media] ([Id], [Title], [OriginalTitle], [Overview], [ImagePath], [PosterImage], [TrailerLink], [WatchLink], [AddedDate], [TypeMedia], [RelaseDate], [AgeRate], [IsActive]) VALUES (27, N'Atlas', N'Atlas', N'Una analista antiterrorista que no confía en la inteligencia artificial descubre que esta puede ser su única esperanza cuando una misión para capturar a un robot rebelde sale mal.', N'http://localhost:3000/files/64b1084b-90a3-405f-a3a2-654ef216fb62.jpg', N'http://localhost:3000/files/241fad53-8ed1-4b02-abcc-4aa553f016b3.jpg', N'link/to/trailer', N'link/to/watch', CAST(N'2024-07-26T21:12:00' AS SmallDateTime), N'movie', CAST(N'2024-05-23T00:00:00' AS SmallDateTime), N'b       ', 1)
SET IDENTITY_INSERT [dbo].[Media] OFF
GO
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (1, 1)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (1, 4)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (2, 1)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (3, 1)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (3, 4)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (4, 7)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (5, 6)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (5, 1)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (5, 11)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (6, 1)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (6, 11)
INSERT [dbo].[MediaAvailibleIn] ([MediaId], [PlatformId]) VALUES (7, 3)
GO
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (8, CAST(N'02:00:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (9, CAST(N'01:45:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (10, CAST(N'02:15:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (11, CAST(N'02:05:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (12, CAST(N'01:40:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (13, CAST(N'02:30:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (14, CAST(N'01:30:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (15, CAST(N'01:55:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (16, CAST(N'01:50:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (17, CAST(N'01:45:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (18, CAST(N'02:00:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (19, CAST(N'01:45:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (20, CAST(N'01:35:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (21, CAST(N'01:50:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (22, CAST(N'01:40:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (23, CAST(N'02:10:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (24, CAST(N'01:45:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (25, CAST(N'01:30:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (26, CAST(N'01:50:00' AS Time))
INSERT [dbo].[Movie] ([MediaId], [Duration]) VALUES (27, CAST(N'01:55:00' AS Time))
GO
SET IDENTITY_INSERT [dbo].[Platforms] ON 

INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (2, N'Amazon Prime Video')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (8, N'Apple TV+')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (6, N'Crunchyroll')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (3, N'Disney+')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (7, N'HBO Max')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (4, N'Hulu')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (1, N'Netflix')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (9, N'Paramount+')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (10, N'Peacock')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (5, N'Start +')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (12, N'Starz')
INSERT [dbo].[Platforms] ([Id], [Name]) VALUES (11, N'YouTube')
SET IDENTITY_INSERT [dbo].[Platforms] OFF
GO
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (9, 15, 7, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (5, 9, 10, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (1, 23, 8, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (3, 5, 1, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (2, 23, 7, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (9, 26, 6, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (10, 6, 4, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (6, 12, 10, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (4, 3, 5, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[Ratings] ([UserId], [MediaId], [Rate], [RateDate]) VALUES (4, 8, 4, CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[Season] ON 

INSERT [dbo].[Season] ([Seasonld], [SerieId], [NumSeason], [DateRelease]) VALUES (1, 1, 1, CAST(N'2016-07-15T00:00:00' AS SmallDateTime))
INSERT [dbo].[Season] ([Seasonld], [SerieId], [NumSeason], [DateRelease]) VALUES (2, 2, 1, CAST(N'2011-04-17T00:00:00' AS SmallDateTime))
INSERT [dbo].[Season] ([Seasonld], [SerieId], [NumSeason], [DateRelease]) VALUES (3, 3, 1, CAST(N'2008-01-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Season] ([Seasonld], [SerieId], [NumSeason], [DateRelease]) VALUES (4, 4, 1, CAST(N'2019-12-20T00:00:00' AS SmallDateTime))
INSERT [dbo].[Season] ([Seasonld], [SerieId], [NumSeason], [DateRelease]) VALUES (5, 5, 1, CAST(N'2019-04-06T00:00:00' AS SmallDateTime))
INSERT [dbo].[Season] ([Seasonld], [SerieId], [NumSeason], [DateRelease]) VALUES (6, 6, 1, CAST(N'2019-11-12T00:00:00' AS SmallDateTime))
INSERT [dbo].[Season] ([Seasonld], [SerieId], [NumSeason], [DateRelease]) VALUES (7, 7, 1, CAST(N'2011-12-04T00:00:00' AS SmallDateTime))
SET IDENTITY_INSERT [dbo].[Season] OFF
GO
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 9, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 9, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (6, 24, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (6, 24, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 4, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 4, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 5, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 5, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (2, 8, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (2, 8, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (3, 4, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (3, 4, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (3, 25, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (3, 25, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 23, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 23, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 4, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 4, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 12, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 12, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 24, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 24, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 27, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 27, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (5, 26, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (5, 26, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (2, 27, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (2, 27, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (7, 12, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (7, 12, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 25, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 25, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 5, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (2, 10, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (2, 10, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (9, 14, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (9, 14, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 26, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 26, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 15, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 15, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 22, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (1, 22, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 10, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 10, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (9, 7, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (9, 7, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (5, 12, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (5, 12, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (10, 24, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (7, 26, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (7, 26, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (6, 4, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (6, 4, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 17, N'L', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (4, 17, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (3, 11, N'H', CAST(N'2024-07-26T21:12:00' AS SmallDateTime))
INSERT [dbo].[UserActions] ([UserId], [MediaId], [TypeAction], [ActionDate]) VALUES (3, 11, N'V', CAST(N'2024-07-26T21:17:00' AS SmallDateTime))
GO
SET IDENTITY_INSERT [dbo].[Users] ON 

INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (1, N'JohnDoe', N'$2b$10$w7OKjXU6LKE3FNV0moGbxeSjE0fdvgdjDeTH2qVjZ8KKng4DLOASK', N'john@example.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (2, N'JaneSmith', N'$2b$10$.9aZ9HFcTFin0RsBlbyBXOXG9oDAARNrBcp3d7pHUx4YHnql4aG5u', N'jane@example.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (3, N'AdminUser', N'$2b$10$Ybde5TPXmeDkeJ9auRCjA.B1ecdMMGK0i5AnKVaZSlNVYt0lNDuh.', N'admin@example.com', N'admin')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (4, N'Eder Godinez', N'$2b$10$kljDfmJ5Jlel6UA9vpiMxOKAdMp5a9kohQM7tfzy3RpOOWdDq1ML.', N'Eder@gmail.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (5, N'Nicole Godinez', N'$2b$10$.jK3.RJP4wbHF4oGJK5z5OSNx0aw.DEWHsKoIAj10ORMJyPoUyh0e', N'Nicole@gmail.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (6, N'Alejandra Hurtado', N'$2b$10$zSyn6JehcqPbsFJlyEXiRe67DVCqbPoM1Q9uzlGPKk.F7QUHBLx3q', N'Ale@gmail.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (7, N'Emily Adame', N'$2b$10$Bn6PKAPNIthyAj2WD6vbVedSsJLG3umwiJ7D9mI2sK.gIh6z9jpbO', N'Emily@gmail.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (8, N'Rodrigo Flores', N'$2b$10$hC2kSbxqN9scP8YJ.X1aTebLnQag4PYWvh7w65oPKaKRbs7Vi0kEu', N'Rodriskis@gmail.com', N'admin')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (9, N'Daniel Godinez', N'$2b$10$uVw5.ovXWUutRaIHUmSZd.2wBWQGfau4gECpDbIGNAuZEPgyUMdaK', N'Daniel@gmail.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (10, N'Diego Garibay', N'$2b$10$0DkQ6euUtu/84UQf8CFYhOfL75YrUqmr2cg11kVcezVgyeSliUExu', N'Dieguito@gmail.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (17, N'Eder Salazar', N'$2b$10$zykN69S4vMhC/YvLvNi/DeVKu8nVxcBA5VQ2c4TJQXNznkNNb4aTi', N'eder.godinez26@gmail.com', N'user')
INSERT [dbo].[Users] ([Id], [Name], [Password], [Email], [Role]) VALUES (20, N'Test', N'$2b$10$DxNT4C9Sxd.DiRMYXpUABObCYZS/ME0mldIgp4lBk/Hdy8iHWb9MC', N'eder.godinez@gmail.com', N'user')
SET IDENTITY_INSERT [dbo].[Users] OFF
GO
/****** Object:  Index [UK_Episode_Item]    Script Date: 28/07/2024 06:18:42 p. m. ******/
ALTER TABLE [dbo].[EpisodesList] ADD  CONSTRAINT [UK_Episode_Item] UNIQUE NONCLUSTERED 
(
	[Seasonld] ASC,
	[Episodeld] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Genders__737584F6823E81AD]    Script Date: 28/07/2024 06:18:42 p. m. ******/
ALTER TABLE [dbo].[Genders] ADD UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Platform__737584F696D985BD]    Script Date: 28/07/2024 06:18:42 p. m. ******/
ALTER TABLE [dbo].[Platforms] ADD UNIQUE NONCLUSTERED 
(
	[Name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [UC_UserMedia]    Script Date: 28/07/2024 06:18:42 p. m. ******/
ALTER TABLE [dbo].[Ratings] ADD  CONSTRAINT [UC_UserMedia] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[MediaId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UC_UserAction]    Script Date: 28/07/2024 06:18:42 p. m. ******/
ALTER TABLE [dbo].[UserActions] ADD  CONSTRAINT [UC_UserAction] UNIQUE NONCLUSTERED 
(
	[UserId] ASC,
	[MediaId] ASC,
	[TypeAction] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [UQ__Users__A9D105346317CA72]    Script Date: 28/07/2024 06:18:42 p. m. ******/
ALTER TABLE [dbo].[Users] ADD UNIQUE NONCLUSTERED 
(
	[Email] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
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
ALTER TABLE [dbo].[MediaAvailibleIn]  WITH CHECK ADD FOREIGN KEY([MediaId])
REFERENCES [dbo].[Media] ([Id])
GO
ALTER TABLE [dbo].[MediaAvailibleIn]  WITH CHECK ADD FOREIGN KEY([PlatformId])
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
REFERENCES [dbo].[Media] ([Id])
GO
ALTER TABLE [dbo].[Season] CHECK CONSTRAINT [FK_Serie_Season]
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
/****** Object:  StoredProcedure [dbo].[CreateNewUser]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
    SET NOCOUNT ON;
    DECLARE @UserId INT;

    BEGIN TRY
        INSERT INTO Users (Name, Email, Password)
        VALUES (@Name, @Email, @Password);

        SET @UserId = SCOPE_IDENTITY();

        SELECT @UserId AS UserId;  -- Retorna el ID del usuario creado
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();

        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH
END;
GO
/****** Object:  StoredProcedure [dbo].[DeleteEpisode]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[DeleteMediaById]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[DeleteUser]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[GetRecommendedMediaForUser]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[GetTrendingMovies]    Script Date: 28/07/2024 06:18:42 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetTrendingMovies]
AS
BEGIN
    WITH TrendingMovies AS (
        SELECT TOP 10 UA.MediaId, COUNT(UA.MediaId) AS TrendingRate
        FROM UserActions UA
        INNER JOIN Media ME ON ME.Id = UA.MediaId
        WHERE ME.IsActive = 1 AND UA.TypeAction <> 'H'
        GROUP BY UA.MediaId
        ORDER BY TrendingRate DESC
    )
    SELECT ME.*
    FROM Media ME
    INNER JOIN TrendingMovies TM ON ME.Id = TM.MediaId
    ORDER BY TM.TrendingRate DESC;
END;
GO
/****** Object:  StoredProcedure [dbo].[InsertEpisode]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[RegisterMovie]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[RegisterRating]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[RegisterSerie]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
    @Duration TIME 
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
	 COMMIT TRANSACTION;
END;
GO
/****** Object:  StoredProcedure [dbo].[RegisterUserAction]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateEpisode]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateMovie]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
/****** Object:  StoredProcedure [dbo].[UpdateUserInfo]    Script Date: 28/07/2024 06:18:42 p. m. ******/
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
