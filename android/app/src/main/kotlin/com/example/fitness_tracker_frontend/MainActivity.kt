package com.example.fitness_tracker_frontend

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import androidx.annotation.NonNull
import com.google.android.gms.common.ConnectionResult
import com.google.android.gms.common.GoogleApiAvailability
import com.google.android.gms.fitness.FitnessLocal
import com.google.android.gms.fitness.LocalRecordingClient
import com.google.android.gms.fitness.data.LocalDataType
import com.google.android.gms.fitness.data.LocalDataSet
import com.google.android.gms.fitness.request.LocalDataReadRequest
import java.time.LocalDateTime
import java.time.ZoneId
import java.util.concurrent.TimeUnit
import android.util.Log
import android.content.Context
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.fitness_tracker.android/recording_api"
    private val EVENT_CHANNEL = "com.fitness_tracker.android/step_stream"
    private val TAG = "RecordingApi"

    private lateinit var sensorManager: SensorManager
    private var stepSensor: Sensor? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "checkPlayServices" -> checkPlayServices(result)
                "subscribe" -> subscribe(result)
                "unsubscribe" -> unsubscribe(result)
                "readSteps" -> readSteps(result)
                else -> result.notImplemented()
            }
        }

        // Event Channel for Real-time Sensor Steps
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                private var eventSink: EventChannel.EventSink? = null
                private val sensorEventListener = object : SensorEventListener {
                    override fun onSensorChanged(event: SensorEvent?) {
                        event?.let {
                            if (it.sensor.type == Sensor.TYPE_STEP_COUNTER) {
                                // Returns total steps since boot. 
                                // We send this raw value; Flutter side will handle offsets/diffs.
                                eventSink?.success(it.values[0].toInt())
                            }
                        }
                    }

                    override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                }

                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                    sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
                    stepSensor = sensorManager.getDefaultSensor(Sensor.TYPE_STEP_COUNTER)
                    
                    if (stepSensor != null) {
                        sensorManager.registerListener(sensorEventListener, stepSensor, SensorManager.SENSOR_DELAY_FASTEST)
                    } else {
                        eventSink?.error("SENSOR_UNAVAILABLE", "Step Counter Sensor not found", null)
                    }
                }

                override fun onCancel(arguments: Any?) {
                    sensorManager.unregisterListener(sensorEventListener)
                    eventSink = null
                }
            }
        )
    }

    private fun checkPlayServices(result: MethodChannel.Result) {
        val googleApiAvailability = GoogleApiAvailability.getInstance()
        val resultCode = googleApiAvailability.isGooglePlayServicesAvailable(this, LocalRecordingClient.LOCAL_RECORDING_CLIENT_MIN_VERSION_CODE)
        if (resultCode == ConnectionResult.SUCCESS) {
            result.success(true)
        } else {
            result.success(false)
        }
    }

    private fun subscribe(result: MethodChannel.Result) {
        val localRecordingClient = FitnessLocal.getLocalRecordingClient(this)
        localRecordingClient.subscribe(LocalDataType.TYPE_STEP_COUNT_DELTA)
            .addOnSuccessListener {
                Log.i(TAG, "Successfully subscribed!")
                result.success(true)
            }
            .addOnFailureListener { e ->
                Log.w(TAG, "There was a problem subscribing.", e)
                result.error("SUBSCRIBE_ERROR", e.message, null)
            }
    }

    private fun unsubscribe(result: MethodChannel.Result) {
        val localRecordingClient = FitnessLocal.getLocalRecordingClient(this)
         localRecordingClient.unsubscribe(LocalDataType.TYPE_STEP_COUNT_DELTA)
            .addOnSuccessListener {
                Log.i(TAG, "Successfully unsubscribed!")
                result.success(true)
            }
            .addOnFailureListener { e ->
                Log.w(TAG, "There was a problem unsubscribing.", e)
                result.error("UNSUBSCRIBE_ERROR", e.message, null)
            }
    }

    private fun readSteps(result: MethodChannel.Result) {
        try {
            val localRecordingClient = FitnessLocal.getLocalRecordingClient(this)
            
            // Get start of today
            val now = LocalDateTime.now()
            val startOfDay = now.toLocalDate().atStartOfDay()
            val zonedDateTimeEnd = now.atZone(ZoneId.systemDefault())
            val zonedDateTimeStart = startOfDay.atZone(ZoneId.systemDefault())

            val readRequest = LocalDataReadRequest.Builder()
                .aggregate(LocalDataType.TYPE_STEP_COUNT_DELTA)
                .bucketByTime(1, TimeUnit.DAYS)
                .setTimeRange(zonedDateTimeStart.toEpochSecond(), zonedDateTimeEnd.toEpochSecond(), TimeUnit.SECONDS)
                .build()

            localRecordingClient.readData(readRequest).addOnSuccessListener { response ->
                var totalSteps = 0
                for (dataSet in response.buckets.flatMap { it.dataSets }) {
                    for (dp in dataSet.dataPoints) {
                        for (field in dp.dataType.fields) {
                            totalSteps += dp.getValue(field).asInt()
                        }
                    }
                }
                result.success(totalSteps) // Return as Int
            }
            .addOnFailureListener { e ->
                 Log.w(TAG,"There was an error reading data", e)
                 result.error("READ_ERROR", e.message, null)
            }
        } catch (e: Exception) {
            Log.e(TAG, "Exception in readSteps", e)
             result.error("READ_EXCEPTION", e.message, null)
        }
    }
}
