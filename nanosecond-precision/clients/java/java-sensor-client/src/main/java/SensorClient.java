import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Properties;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;

import org.bson.Document;

/**
 * Demo Client for MongoDB Native Time Series.
 * Inserts sensor readings into a MDB Time Series collection.
 * The sensor readings are read in from a pre-generated file in JSON format.
 */
public final class SensorClient {

    private String mdbURI;
    private String inputFile;
    private String targetDB;
    private String targetCollection;

    private SensorClient() {
    }

    private void getDemoConfig() throws IOException {

        File configFile = new File("config.properties");

        try {
            
            FileReader reader = new FileReader(configFile);
            Properties config = new Properties();
            config.load(reader);
            System.out.println("Settings:");
        
            mdbURI = config.getProperty("mongodb.uri");
            System.out.println("  MonogDB URI: " + mdbURI);

            inputFile = config.getProperty("inputFile");
            System.out.println("  Sensor readings input file: " + inputFile);

            targetDB = config.getProperty("targetDB");
            System.out.println("  Target Database: " + targetDB);

            targetCollection = config.getProperty("targetCollection");
            System.out.println("  Target Collection: " + targetCollection);


            reader.close();
        } catch (FileNotFoundException ex) {
            System.out.println("ERROR: Configuration file (config.properties) not found. Exiting.");
            System.exit(1);
        } 

    }

    private void run() {

        try {

            // Get demo config settings.
            getDemoConfig();

            try {

                MongoClient mdbClient = MongoClients.create(mdbURI);
                MongoDatabase mdbDatabase = mdbClient.getDatabase(targetDB);
                // Check for existence of Time Series collection.
                boolean collectionExists = mdbDatabase.listCollectionNames()
                            .into(new ArrayList<String>()).contains(targetCollection);
                if (!collectionExists) {
                    System.out.println("ERROR: Target time series collection (" + targetDB + "." + targetCollection + ") does not exist.");
                    System.out.println("Time series collections must be explicitly created.");
                    System.out.println("Use included scripts to create the collection, then rerun this client.");
                    System.out.println("Exiting.");
                    System.exit(0);
                }

                MongoCollection<Document> sensorCollection = mdbDatabase.getCollection(targetCollection);

                // Open the input file
                // (a collection of pre-generated sensor readings in JSON format)
                FileInputStream sensorStream = new FileInputStream(inputFile);
                BufferedReader br = new BufferedReader(new InputStreamReader(sensorStream));

                // Read File Line By Line
                String strLine;
                while ((strLine = br.readLine()) != null)   {

                    // Print sensor reading to the console
                    System.out.println (strLine);

                    // Insert sensor reading into database collection
                    Document sensorReading = Document.parse(strLine);
                    sensorCollection.insertOne(sensorReading);

                }

                // Close the input stream
                sensorStream.close();

            } catch (FileNotFoundException e) {
                System.out.println("ERROR: Input data file not found (" + inputFile + "). Exiting.");
            }


        } catch (Exception e) {
            System.out.println("ERROR: Unexpected error.");
            e.printStackTrace();
        }

    }


    /**
     * @param args The arguments of the program.
     */
    public static void main(String[] args) {
        
        System.out.println("MongoDB Native Time Series: Demonstration Sensor Client.");
        
        SensorClient sensorClient = new SensorClient();
        sensorClient.run();
        
    }

}
