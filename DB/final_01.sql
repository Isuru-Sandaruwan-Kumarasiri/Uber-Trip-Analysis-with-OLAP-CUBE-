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




CREATE TABLE DimDate (
    DateKey INT PRIMARY KEY,         -- YYYYMMDDHH
    FullDate DATE,
    Year INT,
    Month INT,
    Day INT
    
);


CREATE TABLE DimTime (
    TimeKey INT PRIMARY KEY,   -- e.g., 1305 for 13:05
    FullTime TIME,
    Hour INT,
    Minute INT,
    TimeOfDay NVARCHAR(50)     -- Morning / Afternoon / Evening / Night
);


CREATE TABLE DimCustomer (
    CustomerKey INT PRIMARY KEY IDENTITY(1,1),
    CustomerID NVARCHAR(50),
    CustomerRating FLOAT
);

CREATE TABLE DimVehicle (
    VehicleKey INT PRIMARY KEY IDENTITY(1,1),
    VehicleType NVARCHAR(50),
    AvgVTAT FLOAT,
    AvgCTAT FLOAT
);




CREATE TABLE DimLocation (
    LocationKey INT PRIMARY KEY IDENTITY(1,1),
    PickupLocation NVARCHAR(255),
    DropLocation NVARCHAR(255)

);



CREATE TABLE DimCancellationReason (
    ReasonKey INT PRIMARY KEY IDENTITY(1,1),
    ReasonType NVARCHAR(50),  -- 'Customer' or 'Driver'
    ReasonDescription NVARCHAR(255)
);


CREATE TABLE DimPaymentMethod (
    PaymentKey INT PRIMARY KEY IDENTITY(1,1),
    PaymentMethod NVARCHAR(50)
);

CREATE TABLE DimBookingStatus (
    StatusKey INT IDENTITY(1,1) PRIMARY KEY,
    BookingStatus NVARCHAR(50)
);


----------------------------------------------------------------------------------


INSERT INTO DimDate (DateKey, FullDate, Year, Month, Day)
SELECT 
    CONVERT(INT, FORMAT([Date], 'yyyyMMdd')) AS DateKey,
    [Date],
    YEAR([Date]),
    MONTH([Date]),
    DAY([Date])
FROM stg_RideBookings
GROUP BY [Date];

SELECT * FROM DimDate


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


INSERT INTO DimCustomer (CustomerID, CustomerRating)
SELECT DISTINCT
    CustomerID,
    CustomerRating
FROM stg_RideBookings;

SELECT * FROM DimCustomer





INSERT INTO DimVehicle (VehicleType, AvgVTAT, AvgCTAT)
SELECT DISTINCT
    VehicleType,
    AVG(AvgVTAT) OVER(PARTITION BY VehicleType) AS AvgVTAT,
    AVG(AvgCTAT) OVER(PARTITION BY VehicleType) AS AvgCTAT
FROM stg_RideBookings;



SELECT * FROM DimVehicle




INSERT INTO DimLocation (PickupLocation,DropLocation)
SELECT DISTINCT PickupLocation,
        DropLocation
FROM stg_RideBookings;

SELECT * FROM DimLocation




INSERT INTO DimCancellationReason (ReasonType, ReasonDescription)
SELECT DISTINCT 'Customer', ReasonCustomer
FROM stg_RideBookings
WHERE ReasonCustomer IS NOT NULL;

INSERT INTO DimCancellationReason (ReasonType, ReasonDescription)
SELECT DISTINCT 'Driver', ReasonDriver
FROM stg_RideBookings
WHERE ReasonDriver IS NOT NULL;


SELECT * FROM DimCancellationReason




INSERT INTO DimPaymentMethod (PaymentMethod)
SELECT DISTINCT PaymentMethod
FROM stg_RideBookings;

SELECT * FROM DimCancellationReason




INSERT INTO DimBookingStatus (BookingStatus)
SELECT DISTINCT BookingStatus
FROM stg_RideBookings;


SELECT * FROM DimBookingStatus




















-----------------------------------------------
-- Create the Fact Table for Ride Bookings
CREATE TABLE FactRideBookings (
    FactID INT PRIMARY KEY IDENTITY(1,1),
    BookingID NVARCHAR(50) NOT NULL,
    
    -- Foreign Keys to Dimension Tables
    DateKey INT,
    TimeKey INT,
    CustomerKey INT,
    VehicleKey INT,
    LocationKey INT,
    PaymentKey INT,
    CustomerCancelReasonKey INT NULL,
    DriverCancelReasonKey INT NULL,
    
    -- Fact Measures
    BookingValue FLOAT,
    RideDistance FLOAT,
    DriverRatings FLOAT,
    
    -- Status and Flags
    BookingStatus NVARCHAR(50),
    CancelledByCustomer INT,
    CancelledByDriver INT,
    IncompleteRides INT,
    IncompleteReason NVARCHAR(255),
    
    -- Foreign Key Constraints
    CONSTRAINT FK_FactRideBookings_Date FOREIGN KEY (DateKey) REFERENCES DimDate(DateKey),
    CONSTRAINT FK_FactRideBookings_Time FOREIGN KEY (TimeKey) REFERENCES DimTime(TimeKey),
    CONSTRAINT FK_FactRideBookings_Customer FOREIGN KEY (CustomerKey) REFERENCES DimCustomer(CustomerKey),
    CONSTRAINT FK_FactRideBookings_Vehicle FOREIGN KEY (VehicleKey) REFERENCES DimVehicle(VehicleKey),
    CONSTRAINT FK_FactRideBookings_Location FOREIGN KEY (LocationKey) REFERENCES DimLocation(LocationKey),
    CONSTRAINT FK_FactRideBookings_Payment FOREIGN KEY (PaymentKey) REFERENCES DimPaymentMethod(PaymentKey),
    CONSTRAINT FK_FactRideBookings_CustomerCancelReason FOREIGN KEY (CustomerCancelReasonKey) REFERENCES DimCancellationReason(ReasonKey),
    CONSTRAINT FK_FactRideBookings_DriverCancelReason FOREIGN KEY (DriverCancelReasonKey) REFERENCES DimCancellationReason(ReasonKey)
);

-- Insert data into the Fact Table from staging table
INSERT INTO FactRideBookings (
    BookingID,
    DateKey,
    TimeKey,
    CustomerKey,
    VehicleKey,
    LocationKey,
    PaymentKey,
    CustomerCancelReasonKey,
    DriverCancelReasonKey,
    BookingValue,
    RideDistance,
    DriverRatings,
    BookingStatus,
    CancelledByCustomer,
    CancelledByDriver,
    IncompleteRides,
    IncompleteReason
)
SELECT 
    stg.BookingID,
    
    -- Date Key
    dd.DateKey,
    
    -- Time Key (convert TIME to integer format HHMM)
    dt.TimeKey,
    
    -- Customer Key
    dc.CustomerKey,
    
    -- Vehicle Key
    dv.VehicleKey,
    
    -- Location Key
    dl.LocationKey,
    
    -- Payment Method Key
    dp.PaymentKey,
    
    -- Customer Cancellation Reason Key
    dcr_customer.ReasonKey AS CustomerCancelReasonKey,
    
    -- Driver Cancellation Reason Key
    dcr_driver.ReasonKey AS DriverCancelReasonKey,
    
    -- Measures
    stg.BookingValue,
    stg.RideDistance,
    stg.DriverRatings,
    
    -- Status and Flags
    stg.BookingStatus,
    stg.CancelledByCustomer,
    stg.CancelledByDriver,
    stg.IncompleteRides,
    stg.IncompleteReason

FROM stg_RideBookings stg

-- Join with Date Dimension
LEFT JOIN DimDate dd ON dd.FullDate = stg.[Date]

-- Join with Time Dimension (convert staging time to TimeKey format)
LEFT JOIN DimTime dt ON dt.TimeKey = (DATEPART(HOUR, stg.[Time]) * 100 + DATEPART(MINUTE, stg.[Time]))

-- Join with Customer Dimension
LEFT JOIN DimCustomer dc ON dc.CustomerID = stg.CustomerID 
    AND dc.CustomerRating = stg.CustomerRating

-- Join with Vehicle Dimension
LEFT JOIN DimVehicle dv ON dv.VehicleType = stg.VehicleType

-- Join with Location Dimension
LEFT JOIN DimLocation dl ON dl.PickupLocation = stg.PickupLocation 
    AND dl.DropLocation = stg.DropLocation

-- Join with Payment Method Dimension
LEFT JOIN DimPaymentMethod dp ON dp.PaymentMethod = stg.PaymentMethod

-- Join with Customer Cancellation Reason (optional)
LEFT JOIN DimCancellationReason dcr_customer ON dcr_customer.ReasonType = 'Customer' 
    AND dcr_customer.ReasonDescription = stg.ReasonCustomer

-- Join with Driver Cancellation Reason (optional)
LEFT JOIN DimCancellationReason dcr_driver ON dcr_driver.ReasonType = 'Driver' 
    AND dcr_driver.ReasonDescription = stg.ReasonDriver;

-- Verify the data load
SELECT 
    COUNT(*) as TotalRecords,
    COUNT(DISTINCT BookingID) as UniqueBookings,
    SUM(BookingValue) as TotalBookingValue,
    AVG(RideDistance) as AvgRideDistance,
    SUM(CancelledByCustomer) as CustomerCancellations,
    SUM(CancelledByDriver) as DriverCancellations,
    SUM(IncompleteRides) as IncompleteRides
FROM FactRideBookings;


SELECT * FROM FactRideBookings
TRUNCATE TABLE FactRideBookings


ALTER TABLE FactRideBookings 
ADD StatusKey INT;

ALTER TABLE FactRideBookings 
ADD CONSTRAINT FK_FactRideBookings_BookingStatus 
FOREIGN KEY (StatusKey) REFERENCES DimBookingStatus(StatusKey);






UPDATE f
SET f.StatusKey = ds.StatusKey
FROM FactRideBookings f
INNER JOIN DimBookingStatus ds ON f.BookingStatus = ds.BookingStatus;