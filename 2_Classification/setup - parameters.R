
par <- list()

par$projCDL    <- "+proj=aea +lat_0=23 +lon_0=-96 +lat_1=29.5 +lat_2=45.5 +x_0=0 +y_0=0 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"
par$projLandIQ <- "+proj=aea +lat_0=0 +lon_0=-120 +lat_1=34 +lat_2=40.5 +x_0=0 +y_0=-4000000 +ellps=GRS80 +datum=NAD83 +units=m +no_defs"

par$kern_years <- 2007:2020
par$cdl_years <- 2007:2020

par$LandIQ_CROPTYP2 <- list(
        "C" = "Citrus",
        "C4" = "Dates",
        "C5" = "Avocados",
        "C6" = "Olives",
        "C7" = "Miscellaneous subtropical fruit",
        "C8" = "Kiwis",
        "D1" = "Apples",
        "D10" = "Miscellaneous deciduous",
        "D11" = "Mixed deciduous",
        "D12" = "Almonds",
        "D13" = "Walnuts",
        "D14" = "Pistachios",
        "D15" = "Pomegranates",
        "D16" = "Plums",
        "D3" = "Cherries",
        "D5" = "Peaches and nectarines",
        "D6" = "Pears",
        "F" = "Field crops", # only one obs
        "F1" = "Cotton",
        "F10" = "Beans (dry)",
        "F11" = "Miscellaneous field",
        "F12" = "Sunflowers",
        "F16" = "Corn, Sorghum or Sudan",
        "F2" = "Safflower",
        "G" = "Grain and hay crops",
        "G2" = "Wheat",
        "G6" = " Miscellaneous grain and hay",
        "I2" = "new lands being prepared for crop production",
        "P" = "Pasture",
        "P1" = "Alfalfa",
        "P3" = "Mixed pasture",
        "P4" = "Native pasture",
        "P6" = "Miscellaneous grasses",
        "R1" = "Rice",
        "R2" = "Wild Rice",
        "T" = "Truck, nursery & berry crops",
        "T10" = "Onions & garlic",
        "T12" = "Potatoes",
        "T15" = "Tomatoes",
        "T16" = "Flowers, nursery & Christmas tree farms",
        "T18" = "Miscellaneous truck",
        "T19" = "Bush berries",
        "T20" = "Strawberries",
        "T21" = "Peppers (chili, bell, etc.)",
        "T27" = "Greenhouse",
        "T30" = "Lettuce",
        "T31" = " Potato or Sweet potato",
        "T4" = "Cole crops (mixture of 22-25)",
        "T6" = "Carrots",
        "T9" = "Melons, squash, and cucumbers (all types)",
        "U" = "Urban",
        "V" = "Grapes",
        "V2" = "Wine grapes", # only four obs
        "X" = "Not cropped",
        "YP" = "YP"
)
