// MSPT BACKEND - FastAPI
final String baseURI =
    "http://10.42.0.1:8000/"; // "/"; // dev1
// final String baseURI =  "http://192.168.43.237:8000/"; // dev2
// final String baseURI =  "https://sagetrader.herokuapp.com/"; // live
final String serverURI = "${baseURI}api/v1/";

// Check for Neteork Aceess Mobile or wifi
final bool checkForNetowk = false;

// CLOUDINARY IMAGE STORE
final String cloudName = "d3sage";
final String apiKey = "979235147696769";
final String apiSecret = "4QrvbQ_BDUw32ns6WeIf6pABf6U";
final String apiEnvironmentVariable =
    "cloudinary://979235147696769:4QrvbQ_BDUw32ns6WeIf6pABf6U@d3sage";
final String baseDeliveryURL = "http://res.cloudinary.com/d3sage";
final String secureDeliveryURL = "https://res.cloudinary.com/d3sage";
final String apiBaseURL =
    "https://api.cloudinary.com/v1_1/d3sage"; // added /upload
final String testingPreset = "mspt_testing";
final String msptPreset = "mspt_osok";
final String cloudinaryAPI =
    "https://$apiKey:$apiSecret@api.cloudinary.com/v1_1/d3sage";
