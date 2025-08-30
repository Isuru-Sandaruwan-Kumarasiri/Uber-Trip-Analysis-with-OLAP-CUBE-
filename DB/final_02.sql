CREATE TABLE stg_RideBookings (
    [Date] DATE,
    [Time] TIME,
    BookingID NVARCHAR(50),
    BookingStatus NVARCHAR(50),
    CustomerID NVARCHAR(50),
    VehicleType NVARCHAR(50),
    PickupLocation NVARCHAR(255),
    DropLocation NVARCHAR(255),
    AvgVTAT FLOAT,
    AvgCTAT FLOAT,
    CancelledByCustomer INT,
    ReasonCustomer NVARCHAR(255),
    CancelledByDriver INT,
    ReasonDriver NVARCHAR(255),
    IncompleteRides INT,
    IncompleteReason NVARCHAR(255),
    BookingValue FLOAT,
    RideDistance FLOAT,
    DriverRatings FLOAT,
    CustomerRating FLOAT,
    PaymentMethod NVARCHAR(50)
);




Select * From stg_RideBookings

truncate table stg_RideBookings



CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,         -- YYYYMMDDHH
    FullDate DATE,
    Year INT,
    Month INT,
    Day INT
    
);


CREATE TABLE DimCustomer (
    CustomerKey INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID NVARCHAR(50)
);


CREATE TABLE DimVehicle (
    VehicleKey INT IDENTITY(1,1) PRIMARY KEY,
    VehicleType NVARCHAR(50)
);


CREATE TABLE DimLocation (
    LocationKey INT IDENTITY(1,1) PRIMARY KEY,
    PickupLocation NVARCHAR(255),
    DropLocation NVARCHAR(255)
);

CREATE TABLE DimPaymentMethod (
    PaymentKey INT IDENTITY(1,1) PRIMARY KEY,
    PaymentMethod NVARCHAR(50)
);


CREATE TABLE DimBookingStatus (
    StatusKey INT IDENTITY(1,1) PRIMARY KEY,
    BookingStatus NVARCHAR(50)
);



CREATE TABLE FactRides (
    RideKey BIGINT IDENTITY(1,1) PRIMARY KEY,
    DateKey INT FOREIGN KEY REFERENCES DimDate(DateKey),
    CustomerKey INT FOREIGN KEY REFERENCES DimCustomer(CustomerKey),
    VehicleKey INT FOREIGN KEY REFERENCES DimVehicle(VehicleKey),
    LocationKey INT FOREIGN KEY REFERENCES DimLocation(LocationKey),
    PaymentKey INT FOREIGN KEY REFERENCES DimPaymentMethod(PaymentKey),
    StatusKey INT FOREIGN KEY REFERENCES DimBookingStatus(StatusKey),

    BookingValue FLOAT,
    RideDistance FLOAT,
    AvgVTAT FLOAT,
    AvgCTAT FLOAT,
    CancelledByCustomer INT,
    CancelledByDriver INT,
    IncompleteRides INT,
    DriverRating FLOAT,
    CustomerRating FLOAT
);




INSERT INTO DimDate (DateKey, FullDate, Year, Month, Day)
SELECT
    CONVERT(INT, FORMAT(Date, 'yyyyMMdd')) AS DateKey,  -- now only YYYYMMDD
    CAST(Date AS DATE) AS FullDate,
    YEAR(Date) AS Year,
    MONTH(Date) AS Month,
    DAY(Date) AS Day
FROM stg_RideBookings
GROUP BY Date;


select * from DimDate



INSERT INTO DimCustomer (CustomerID)
SELECT DISTINCT REPLACE(CustomerID, '"', '') AS CustomerID
FROM stg_RideBookings;


select * from DimCustomer
truncate table DimCustomer


INSERT INTO DimVehicle (VehicleType)
SELECT DISTINCT VehicleType
FROM stg_RideBookings;


select * from DimVehicle



INSERT INTO DimLocation (PickupLocation, DropLocation)
SELECT DISTINCT PickupLocation, DropLocation
FROM stg_RideBookings;

select * from DimLocation



INSERT INTO DimPaymentMethod (PaymentMethod)
SELECT DISTINCT PaymentMethod
FROM stg_RideBookings;

select * from DimPaymentMethod




INSERT INTO DimBookingStatus (BookingStatus)
SELECT DISTINCT BookingStatus
FROM stg_RideBookings;

select * from DimBookingStatus




INSERT INTO FactRides (
    DateKey, CustomerKey, VehicleKey, LocationKey, PaymentKey, StatusKey,
    BookingValue, RideDistance, AvgVTAT, AvgCTAT,
    CancelledByCustomer, CancelledByDriver, IncompleteRides,
    DriverRating, CustomerRating
)
SELECT
    d.DateKey,
    c.CustomerKey,
    v.VehicleKey,
    l.LocationKey,
    p.PaymentKey,
    s.StatusKey,
    r.BookingValue,
    r.RideDistance,
    r.AvgVTAT,
    r.AvgCTAT,
    r.CancelledByCustomer,
    r.CancelledByDriver,
    r.IncompleteRides,
    r.DriverRatings,
    r.CustomerRating
FROM stg_RideBookings r
JOIN DimDate d ON CONVERT(INT, FORMAT(r.Date, 'yyyyMMdd')) = d.DateKey
JOIN DimCustomer c ON REPLACE(r.CustomerID, '"', '') = c.CustomerID
JOIN DimVehicle v ON r.VehicleType = v.VehicleType
JOIN DimLocation l ON r.PickupLocation = l.PickupLocation AND r.DropLocation = l.DropLocation
JOIN DimPaymentMethod p ON r.PaymentMethod = p.PaymentMethod
JOIN DimBookingStatus s ON r.BookingStatus = s.BookingStatus;

select * from FactRides            





------------------------------------------------


CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY,   -- e.g., 1305 for 13:05
    FullTime TIME,
    Hour INT,
    Minute INT,
    TimeOfDay NVARCHAR(50)     -- Morning / Afternoon / Evening / Night
);

;WITH TimeCTE AS (
    SELECT CAST(0 AS INT) AS n
    UNION ALL
    SELECT n + 1 FROM TimeCTE WHERE n < 1439  -- 1440 minutes = 24 hours
)
INSERT INTO DimTime (TimeKey, FullTime, Hour, Minute, TimeOfDay)
SELECT 
    (DATEPART(HOUR, DATEADD(MINUTE, n, '00:00')) * 100) 
      + DATEPART(MINUTE, DATEADD(MINUTE, n, '00:00')) AS TimeKey,
    CAST(DATEADD(MINUTE, n, '00:00') AS TIME) AS FullTime,
    DATEPART(HOUR, DATEADD(MINUTE, n, '00:00')) AS Hour,
    DATEPART(MINUTE, DATEADD(MINUTE, n, '00:00')) AS Minute,
    CASE 
        WHEN DATEPART(HOUR, DATEADD(MINUTE, n, '00:00')) BETWEEN 5 AND 11 THEN 'Morning'
        WHEN DATEPART(HOUR, DATEADD(MINUTE, n, '00:00')) BETWEEN 12 AND 16 THEN 'Afternoon'
        WHEN DATEPART(HOUR, DATEADD(MINUTE, n, '00:00')) BETWEEN 17 AND 20 THEN 'Evening'
        ELSE 'Night'
    END AS TimeOfDay
FROM TimeCTE
OPTION (MAXRECURSION 0);


select * from DimTime


ALTER TABLE FactRides
ADD TimeKey INT NULL;


UPDATE F
SET F.TimeKey = T.TimeKey
FROM FactRides F
JOIN DimTime T
  ON DATEPART(HOUR, F.[Time]) = T.Hour
 AND DATEPART(MINUTE, F.[Time]) = T.Minute;


 select * from FactRides


ALTER TABLE FactRides
ADD BookingID NVARCHAR(50);


INSERT INTO FactRides (DateKey, TimeKey, VehicleKey, CustomerKey, TotalRides, CancelledRides, TotalFare)
SELECT 
    (YEAR([Date])*10000 + MONTH([Date])*100 + DAY([Date])) AS DateKey,
    (DATEPART(HOUR, [Time]) * 100 + DATEPART(MINUTE, [Time])) AS TimeKey,
    V.VehicleKey,
    C.CustomerKey,
    COUNT(*) AS TotalRides,
    SUM(CASE WHEN BookingStatus = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledRides,
    SUM(Fare) AS TotalFare
FROM stg_RideBookings S
JOIN DimVehicle V ON S.VehicleType = V.VehicleType
JOIN DimCustomer C ON S.CustomerID = C.CustomerID
GROUP BY 
    (YEAR([Date])*10000 + MONTH([Date])*100 + DAY([Date])),
    (DATEPART(HOUR, [Time]) * 100 + DATEPART(MINUTE, [Time])),
    V.VehicleKey,
    C.CustomerKey;

