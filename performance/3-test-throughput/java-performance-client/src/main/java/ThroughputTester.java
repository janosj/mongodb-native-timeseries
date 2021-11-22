// For processing command line arguments
import org.apache.commons.cli.*;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.time.Duration;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import java.io.FileReader;
import java.io.File;
import java.util.Properties;

import com.mongodb.client.MongoClient;
import com.mongodb.client.MongoClients;
import com.mongodb.client.MongoCollection;
import com.mongodb.client.MongoDatabase;
import com.mongodb.client.model.InsertManyOptions;

import org.bson.Document;

/**
 * Demo Client for MongoDB Native Time Series.
 * Inserts sensor readings into a MDB Time Series collection.
 * The sensor readings are read in from a pre-generated file in JSON format.
 */
public final class ThroughputTester extends Thread {

    private Thread t;
    private String threadName;
 
    // Available options. Specify through command line.
    private static String mdbURI;
    private static String inputFile;
    private static int batchSize;
    private static String targetDB;
    private static String targetCollection;
    private static int numThreads;
    private static boolean doInserts = true;

    private int messagesProcessed = 0;
    private long timeElapsedMs = 0;

    public ThroughputTester(String threadName) {
        this.threadName  = threadName;
    }

    public void start () {
        System.out.println("Starting thread " + threadName );
        if (t == null) {
           t = new Thread (this, threadName);
           t.start ();
        }
     }



    // Inserts individual sensor readings, one by one
    private int insertIndividually(BufferedReader localBr, MongoCollection<Document> localCollection) throws IOException {

        int counter = 0;
        String strLine;
        while ((strLine = localBr.readLine()) != null)   {

            // Print sensor reading to the console
            //System.out.println (strLine);

            // Insert sensor reading into database collection
            Document sensorReading = Document.parse(strLine);
            localCollection.insertOne(sensorReading);

            counter++;
        }
        return counter;

    }

    // Inserts in bulk
    private int insertBulk(BufferedReader localBr, MongoCollection<Document> localCollection) throws IOException {

        List<Document> sensorReadings = new ArrayList<>();

        InsertManyOptions options = new InsertManyOptions();
        //if (!ordered) {
            options.ordered(false);
        //}

        int totalCount = 0;
        int countThisBatch = 0;
        int batchCount = 0;
        String strLine;

        Document newMeta = new Document("sensorID", threadName);;
        while ((strLine = localBr.readLine()) != null)   {

            // Print sensor reading to the console
            //System.out.println (strLine);

            // Insert sensor reading into database collection
            Document sensorReading = Document.parse(strLine);
            sensorReading.append("metadata", newMeta);
            sensorReadings.add(sensorReading);
            countThisBatch++;
            totalCount++;

            //System.out.println(sensorReading.toString());
            //Document sensorMeta = (Document)sensorReading.get("metadata");
            //String sensorID = sensorMeta.get("sensorID").toString();
            //System.out.println(sensorReading.toString());

            if (countThisBatch == batchSize) {
                if (doInserts) {
                    localCollection.insertMany(sensorReadings, options);
                }
                batchCount++;
                countThisBatch = 0;
                System.out.println("  " + threadName + " Batch " + batchCount + ": " + totalCount);
            }

        }

        if (countThisBatch > 0) {
            localCollection.insertMany(sensorReadings);
            batchCount++;
        }

        return totalCount;

    }

    public void run() {

        try {

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

                // Start the timer
                Instant start = Instant.now();

                // int recordCount = insertIndividually(br, sensorCollection);
                int recordCount = insertBulk(br, sensorCollection);

                // Stop the timer
                Instant finish = Instant.now();

                // Close the input stream
                sensorStream.close();

                messagesProcessed = recordCount;
                timeElapsedMs = Duration.between(start, finish).toMillis();
                double messagesPerSec = ( (double)recordCount / (double)timeElapsedMs ) * 1000;

                System.out.print("Tester finished. ");
                System.out.print("Time Elapsed: " + timeElapsedMs + " ms. ");
                System.out.println(messagesPerSec + " messages per second.");
    
            } catch (FileNotFoundException e) {
                System.out.println("ERROR: Input data file not found (" + inputFile + "). Exiting.");
            }

        } catch (Exception e) {
            System.out.println("ERROR: Unexpected error.");
            e.printStackTrace();
        }

    }

    public int getMessageCount() {
        return messagesProcessed;
    }
    public long getTimeElapsedMs () {
        return timeElapsedMs;
    }

    // Used to read from a properties file
    /*
    private static void getDemoConfig() throws IOException {

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
    */

    // Pull configuration from command-line arguments
    private static void getDemoConfig(String[] args) {

        System.out.println("Fetching test options...");
        Options options = new Options();

        // Defaults to localhost:27017 (no auth)
        Option mdbUriOption = new Option("h", "uri", true, "MongoDB URI");
        mdbUriOption.setRequired(false);
        options.addOption(mdbUriOption);

        Option inputFileOption = new Option("i", "file", true, "input file");
        inputFileOption.setRequired(true);
        options.addOption(inputFileOption);

        // Defaults to 1 (single-threaded)
        Option threadsOption = new Option("t", "threads", true, "number of threads");
        threadsOption.setRequired(false);
        options.addOption(threadsOption);

        // Defaults to 1 (no bulk inserts)
        Option batchSizeOption = new Option("b", "batchSize", true, "batch size for bulk inserts (1 indicates no bulk inserts)");
        batchSizeOption.setRequired(false);
        options.addOption(batchSizeOption);

        Option dbOption = new Option("d", "db", true, "target database");
        dbOption.setRequired(false);
        options.addOption(dbOption);

        Option collectionOption = new Option("c", "coll", true, "target collection");
        collectionOption.setRequired(false);
        options.addOption(collectionOption);

        // Fake mode does everything except the actual inserts.
        // For testing throughput of the tester itself.
        Option fakeOption = new Option("f", "fake", false, "fake mode (no inserts)");
        fakeOption.setRequired(false);
        options.addOption(fakeOption);

        CommandLineParser parser = new DefaultParser();
        HelpFormatter formatter = new HelpFormatter();
        CommandLine cmd = null;//not a good practice, it serves it purpose 

        try {
            cmd = parser.parse(options, args);
        } catch (ParseException e) {
            System.out.println(e.getMessage());
            formatter.printHelp("ThroughputTester", options);
            System.exit(1);
        }

        // Defaults to localhost:27017 (no auth)
        mdbURI = cmd.getOptionValue("uri");
        if (mdbURI == null) {
            System.out.println("  MDB URI:           not specified - defaulting to localhost:27017 (no auth)");
            // Guidance is to set retryableWrites to false for time series 
            mdbURI = "mongodb://localhost:27017/?retryWrites=false";
        }
        if (!mdbURI.contains("retryWrites=false")) {
            System.out.println("    ** Note: check connect string - retryWrites should be set to false");
        }

        inputFile = cmd.getOptionValue("file");
        System.out.println("  Input File:        " + inputFile);

        targetDB = cmd.getOptionValue("db");
        if (targetDB == null) {
            targetDB = "tsperf";
        }

        targetCollection = cmd.getOptionValue("coll");
        if (targetCollection == null) {
            targetCollection = "sensorReadings";
        }

        String numThreadsStr = cmd.getOptionValue("threads");
        if (numThreadsStr == null) {
            System.out.println("  Number of threads: not specified - defaulting to single-threaded");
            numThreads = 1;
        } else {
            numThreads = Integer.parseInt(numThreadsStr);
            System.out.println("  Number of threads: " + numThreads);
        }

        String batchSizeStr = cmd.getOptionValue("batchSize");
        if (batchSizeStr == null) {
            System.out.println("  Batch Size:        not specified - defaulting to 1 (no bulk inserts)");
            batchSize = 1;
        } else {
            batchSize = Integer.parseInt(batchSizeStr);
            System.out.println("  Batch Size:        " + batchSize);
        }

        if (cmd.hasOption("fake")) {
            doInserts = false;
            System.out.println("  Fake set to true - nothing will be inserted.");
        };

        System.out.println("");

    }

    /**
     * @param args The arguments of the program.
     */
    public static void main(String[] args) {
        
        System.out.println("");
        System.out.println("MongoDB Native Time Series: Throughput Tester");
        System.out.println("---------------------------------------------");
        System.out.println("");

        // Get demo config settings.
        //getDemoConfig();     // Was using a properties file, switched to command line.
        getDemoConfig(args);

        // Disables some non-essential console messages.
        Logger.getLogger("org.mongodb.driver").setLevel(Level.WARNING);

        System.out.println("Executing test...");
        try {

            Thread allThreads[]  = new Thread[numThreads];
            ThroughputTester allTesters[] = new ThroughputTester[numThreads];
    
            // Start the timer
            Instant startTime = Instant.now();

            for (int i = 0; i<numThreads; i++) {
                allTesters[i] = new ThroughputTester("T" + i);
                allThreads[i] = new Thread( allTesters[i] );
                System.out.println("Starting thread " + i + "...");
                allThreads[i].start();
            }

            // Wait for all threads to finish.
            int totalMessagesProcessed = 0;
            for (int j = 0; j < numThreads; j++) {
                allThreads[j].join();
                totalMessagesProcessed += allTesters[j].getMessageCount();
            }

            // Stop the timer
            Instant endTime = Instant.now();
            long testElapsedMs = Duration.between(startTime, endTime).toMillis();

            int messagesPerSec = (int) Math.round( (double)totalMessagesProcessed / (double)testElapsedMs * 1000 );
            System.out.println("Main finished.");
            System.out.println( totalMessagesProcessed + " messages processed in " + 
                                testElapsedMs + "ms " + 
                                "(" + messagesPerSec + " messages per second).");

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

}
