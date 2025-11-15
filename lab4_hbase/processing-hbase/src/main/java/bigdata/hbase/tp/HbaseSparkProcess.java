package bigdata.hbase.tp;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.hbase.HBaseConfiguration;
import org.apache.hadoop.hbase.client.Result;
import org.apache.hadoop.hbase.client.Scan;
import org.apache.hadoop.hbase.io.ImmutableBytesWritable;
import org.apache.hadoop.hbase.mapreduce.TableInputFormat;
import org.apache.hadoop.hbase.protobuf.ProtobufUtil;
import org.apache.hadoop.hbase.util.Base64;
import org.apache.hadoop.hbase.util.Bytes;

import org.apache.spark.SparkConf;
import org.apache.spark.api.java.JavaPairRDD;
import org.apache.spark.api.java.JavaSparkContext;

public class HbaseSparkProcess {

    public void startSparkJob() throws Exception {

        // -------------------------------
        // 1. HBase configuration
        // -------------------------------
        Configuration config = HBaseConfiguration.create();
        config.set("hbase.zookeeper.quorum", "hadoop-master"); // your ZK host
        config.set("hbase.zookeeper.property.clientPort", "2181"); // default port
        config.set(TableInputFormat.INPUT_TABLE, "products");

        // -------------------------------
        // 2. Specify a scan with column family "cf"
        // -------------------------------
        Scan scan = new Scan();
        scan.addFamily(Bytes.toBytes("cf"));
        String scanToString = Base64.encodeBytes(ProtobufUtil.toScan(scan).toByteArray());
        config.set(TableInputFormat.SCAN, scanToString);

        // -------------------------------
        // 3. Spark configuration
        // -------------------------------
        SparkConf sparkConf = new SparkConf()
                .setAppName("SparkHBaseTest")
                .setMaster("local[4]");

        JavaSparkContext jsc = new JavaSparkContext(sparkConf);

        // -------------------------------
        // 4. Read HBase table as RDD
        // -------------------------------
        JavaPairRDD<ImmutableBytesWritable, Result> hBaseRDD =
                jsc.newAPIHadoopRDD(
                        config,
                        TableInputFormat.class,
                        ImmutableBytesWritable.class,
                        Result.class
                );

        // -------------------------------
        // 5. Debug: print row keys
        // -------------------------------
        hBaseRDD.foreach(pair -> {
            Result result = pair._2;
            System.out.println("Row key: " + Bytes.toString(result.getRow()));
        });

        // -------------------------------
        // 6. Count rows
        // -------------------------------
        long count = hBaseRDD.count();
        System.out.println("Nombre d'enregistrements : " + count);

        jsc.close();
    }

    public static void main(String[] args) throws Exception {
        HbaseSparkProcess job = new HbaseSparkProcess();
        job.startSparkJob();
    }
}
