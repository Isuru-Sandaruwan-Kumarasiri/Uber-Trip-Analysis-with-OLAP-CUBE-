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
    CustomerRating NVARCHAR(50),
    PaymentMethod NVARCHAR(50)
);


