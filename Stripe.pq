section StripeAugment;

windowWidth = 1200;
windowHeight = 1000;

// Data Source Kind description
StripeAugment = [
    TestConnection = (dataSourcePath) => { "StripeAugment.Navigation" },
    Authentication = [
        UsernamePassword = [
            UsernameLabel="Enter Stripe API key"
        ]
    ],
    Label = Extension.LoadString("DataSourceLabel")
];

// // Data Source UI publishing description
// StripeAugment.Publish = [
//     Beta = false,
//     Category = "Other",
//     ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
//     LearnMoreUrl = "https://github.com/mbilling/pbiconnectors",
//     SourceImage = StripeAugment.Icons,
//     SourceTypeImage = StripeAugment.Icons
// ];


///////////////////////////////////////////////////////////////////////////////////////////////////
//                                      CONNECTOR METADATA
///////////////////////////////////////////////////////////////////////////////////////////////////
[DataSource.Kind="StripeAugment", Publish="StripeAugment.Publish"]
shared StripeAugment.Navigation = Value.ReplaceType(Navigation, NavigationType);

NavigationType = type function () as table meta [                  
        Documentation.Name = "Stripe",
        Documentation.LongDescription = "Accesses all objects available through the Stripe API.",
        Documentation.Examples = {[
            Description = "",
            Code = "",
            Result = ""
        ]}
    ];

 Navigation = () =>
    let
        objects = #table(
            {"Name",                "Key",                      "Data",                     "ItemKind", "ItemName", "IsLeaf"},
            {
                {"Products",        "StripeAugment.Products",          StripeAugment.Products(),          "Table",    "Table",    true}
                // {"Core Resources",  "NavTableCoreResources",    NavTableCoreResources(),    "Folder",   "Folder",   false},
                // {"Subscriptions",   "NavTableSubscriptions",    NavTableSubscriptions(),    "Folder",   "Folder",   false}
            }),
            NavTable = Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf") 
    in
        NavTable;

// NavTableCoreResources = () as table => 
//     let
//         objects = #table(
//             {
//                 "Name",             "Key",                          "Data",                         "ItemKind", "ItemName", "IsLeaf"},{
//                 {"Balance History", "StripeAugment.BalanceHistory",    StripeAugment.BalanceHistory(),    "Table",    "Table",    true},
//                 {"Charges",         "StripeAugment.Charges",           StripeAugment.Charges(),           "Table",    "Table",    true},
//                 {"Customers",       "StripeAugment.Customers",         StripeAugment.Customers(),         "Table",    "Table",    true},
//                 {"Disputes",        "StripeAugment.Disputes",          StripeAugment.Disputes(),          "Table",    "Table",    true},
//                 {"Events",          "StripeAugment.Events",            StripeAugment.Events(),            "Table",    "Table",    true},
//                 {"Payouts",         "StripeAugment.Payouts",           StripeAugment.Payouts(),           "Table",    "Table",    true},
//                 {"Products",        "StripeAugment.Products",          StripeAugment.Products(),          "Table",    "Table",    true},
//                 {"Refunds",         "StripeAugment.Refunds",           StripeAugment.Refunds(),           "Table",    "Table",    true}
//             }),
//         NavTable = Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
//     in
//         NavTable;

// NavTableSubscriptions = () as table => 
//     let
//         objects = #table(
//             {
//                 "Name",             "Key",                      "Data",                             "ItemKind", "ItemName", "IsLeaf"},{
//                 {"Coupons",         "StripeAugment.Coupons",       StripeAugment.Coupons(),               "Table",    "Table",    true},
//                 {"Invoices",        "StripeAugment.Invoices",      StripeAugment.Invoices(),              "Table",    "Table",    true},
//                 {"InvoiceItems",    "StripeAugment.InvoiceItems",  StripeAugment.InvoiceItems(),          "Table",    "Table",    true},
//                 {"Products",        "StripeAugment.Products",      StripeAugment.Products(),              "Table",    "Table",    true},
//                 {"Plans",           "StripeAugment.Plans",         StripeAugment.Plans(),                 "Table",    "Table",    true},
//                 {"Subscriptions",   "StripeAugment.Subscriptions", StripeAugment.Subscriptions(),         "Table",    "Table",    true}
//             }),
//         NavTable = Table.ToNavigationTable(objects, {"Key"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
//     in
//         NavTable;


///////////////////////////////////////////////////////////////////////////////////////////////////
//                                      STRIPE PRODUCTS API
///////////////////////////////////////////////////////////////////////////////////////////////////


[DataSource.Kind="StripeAugment"]
shared StripeAugment.Products = () =>
    let
        columns = {"id", "object", "active", "attributes", "caption", "created", "deactivate_on", "description", "images", "livemode", "metadata", "name", "package_dimensions", "shippable", "skus", "statement_descriptor", "type", "unit_label", "updated", "url"},
        url = "https://api.stripe.com/v1/products?limit=100",
        tableOrEmpty = GetPagedData(url),

        table = if not Table.IsEmpty(tableOrEmpty) then 
            let 
                expandRecords = Table.ExpandRecordColumn(tableOrEmpty, "Column1", columns),
                removedObject = Table.RemoveColumns(expandRecords,{"object"}),
                tableTyped = Table.TransformColumnTypes(removedObject, {{"created", type number}, {"active", type logical}, {"livemode", type logical}, {"shippable", type logical}, {"updated", type number}}),
                createdConverted = ConvertUnixToDateTime(tableTyped, "created"),
                updatedConverted = ConvertUnixToDateTime(createdConverted, "updated")
            in 
                createdConverted
        else 
            #table(columns, {})
    in
        table;


///////////////////////////////////////////////////////////////////////////////////////////////////
//                                      STRIPE SUBSCRIPTIONS API
///////////////////////////////////////////////////////////////////////////////////////////////////


// [DataSource.Kind="StripeAugment"]
// shared StripeAugment.Subscriptions = () =>
//     let
//         columns = {"id", "object", "application_fee_percent", "billing", "cancel_at_period_end", "canceled_at", "created", "current_period_end", "current_period_start", "customer", "days_until_due", "discount", "ended_at", "items", "livemode", "metadata", "plan", "quantity", "start", "status", "tax_percent", "trial_end", "trial_start"},
//         url = "https://api.stripe.com/v1/subscriptions?limit=100",
//         tableOrEmpty = GetPagedData(url),

//         table = if not Table.IsEmpty(tableOrEmpty) then 
//             let
//                 expandRecords = Table.ExpandRecordColumn(tableOrEmpty, "Column1", columns),
//                 removedObject = Table.RemoveColumns(expandRecords,{"object"}),

//                 tableTyped = Table.TransformColumnTypes(removedObject, {{"application_fee_percent", type number}, {"cancel_at_period_end", type logical}, {"canceled_at", type number}, {"created", type number}, {"current_period_end", type number}, {"current_period_start", type number}, {"days_until_due", type number}, {"ended_at", type number}, {"livemode", type logical}, {"quantity", type number}, {"start", type number}, {"tax_percent", type number}, {"trial_end", type number}, {"trial_start", type number}}),
//                 canceledAtConverted = ConvertUnixToDateTime(tableTyped, "canceled_at"),
//                 createdConverted = ConvertUnixToDateTime(canceledAtConverted, "created"),
//                 currentPeriodEndConverted = ConvertUnixToDateTime(createdConverted, "current_period_end"),
//                 currentPeriodStartConverted = ConvertUnixToDateTime(currentPeriodEndConverted, "current_period_start"),
//                 endedAtConverted = ConvertUnixToDateTime(currentPeriodStartConverted, "ended_at"),
//                 startConverted = ConvertUnixToDateTime(endedAtConverted, "start"),
//                 trialEndConverted = ConvertUnixToDateTime(startConverted, "trial_end"),
//                 trialStartConverted = ConvertUnixToDateTime(trialEndConverted, "trial_start")
//             in 
//                 trialStartConverted
//         else 
//             #table(columns, {})
//     in
//         table;


///////////////////////////////////////////////////////////////////////////////////////////////////
//                                      DATA TOOLS
///////////////////////////////////////////////////////////////////////////////////////////////////
_GetPagedData = (url) =>
    let
        seedResult = Json.Document(Web.Contents(url)),
        seedHasMore = seedResult[has_more],
        seedLastId = List.Last(seedResult[data])[id],

        joined_response = if seedHasMore
            then 
                List.Generate(
                    ()=> [result = seedResult, query = url, has_more = seedHasMore, lastId = seedLastId], 
                    each [has_more], 
                    each [
                        query = url & "&" & Uri.BuildQueryString([starting_after=lastId]),
                        result = Json.Document(Web.Contents([query])),
                        lastId = List.Last(result[data])[id],
                        has_more = result[has_more]
                    ], 
                    each [result]
                ) 
            else
                {seedResult},

        table = Table.FromList(joined_response, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
    in
        table;

GetPagedData = (url) =>
    let
        seedResult = Json.Document(Web.Contents(url)),
        seedHasMore = seedResult[has_more],
        seedLastId = List.Last(seedResult[data])[id],

        getPages = (query, result) =>
            let
                response = Json.Document(Web.Contents(query)),
                newResult = List.Combine({result, response[data]}),
                nextQuery = if response[has_more] then url & "&" & Uri.BuildQueryString([starting_after=List.Last(response[data])[id]]) else  null
            in
                if nextQuery <> null then @getPages(nextQuery, newResult) else newResult,

        joined_pages = getPages(url, {}),

        table = Table.FromList(joined_pages, Splitter.SplitByNothing(), null, null, ExtraValues.Error)
    in
        table;


ConvertUnixToDateTime = (TableTyped as table, unixColumn as text) => 
    let 
        AddCreatedAsDateTime = Table.AddColumn(TableTyped, "temp_1", each try #datetime(1970, 1, 1, 0, 0, 0) + #duration(0, 0, 0, Record.Field(_, unixColumn)) otherwise null),
        Typed = Table.TransformColumnTypes(AddCreatedAsDateTime,{{"temp_1", type datetime}}),
        RemovedOriginal = Table.RemoveColumns(Typed,{unixColumn}),
        Converted = Table.RenameColumns(RemovedOriginal,{{"temp_1", unixColumn}})
    in
        Converted;

//// Get the full example on how to create a Navigation Table from Microsoft here > https://github.com/Microsoft/DataConnectors/tree/master/samples/NavigationTable
Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;

//// Function to check if the text string exists or if it should grab the next string
//// Get the full example on why this function was created from Microsoft here > https://github.com/Microsoft/DataConnectors/blob/fe8cb91f694e476bd70c10b9295a815d7bfc42d7/samples/MyGraph/README.md

Value.IfNull = (a, b) => if a <> null then a else b;

//// Function to concatenate all the scopes and create a string for them
//// Get the full example on why this function was created from Microsoft here > https://github.com/Microsoft/DataConnectors/blob/fe8cb91f694e476bd70c10b9295a815d7bfc42d7/samples/MyGraph/README.md
GetScopeString = (scopes as list, optional scopePrefix as text) as text =>
    let
        prefix = Value.IfNull(scopePrefix, ""),
        addPrefix = List.Transform(scopes, each prefix & _),
        asText = Text.Combine(addPrefix, " ")
    in
        asText;

//// Helper function to create sample tables
SampleTable = ( OutputTable as table) as text =>

let
    TableToTransform = Table.FirstN(OutputTable,2),        
    Headers = Text.Combine(List.Transform(Table.ColumnNames(TableToTransform), each """"""&Text.From(_)&""""""), ","),
    Data = Text.Combine(List.Transform(List.Transform(Table.ToRows(TableToTransform), each Text.Combine(List.Transform(_, (_)=> """"""&Text.From(_)&""""""), ",")), each "{"&_&"}"), ","),
    TableFormat = "#table({"&Headers&"},{"&Data&"})"
in
    TableFormat;
