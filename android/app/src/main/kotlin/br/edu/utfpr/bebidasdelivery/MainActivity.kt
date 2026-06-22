package br.edu.utfpr.bebidasdelivery

import android.Manifest
import android.app.Activity
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.MediaStore
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    private val channelName = "bebidasdelivery/native_camera"
    private val cameraRequestCode = 1501
    private val cameraPermissionRequestCode = 1502
    private var pendingResult: MethodChannel.Result? = null
    private var currentPhotoPath: String? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            channelName
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "takeAgePhoto" -> takeAgePhoto(result)
                else -> result.notImplemented()
            }
        }
    }

    private fun takeAgePhoto(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("camera_busy", "A camera ja esta em uso.", null)
            return
        }

        pendingResult = result

        if (
            Build.VERSION.SDK_INT >= Build.VERSION_CODES.M &&
            checkSelfPermission(Manifest.permission.CAMERA) != PackageManager.PERMISSION_GRANTED
        ) {
            requestPermissions(
                arrayOf(Manifest.permission.CAMERA),
                cameraPermissionRequestCode
            )
            return
        }

        openCamera()
    }

    private fun openCamera() {
        try {
            val photoFile = File.createTempFile("maioridade-", ".jpg", cacheDir)
            currentPhotoPath = photoFile.absolutePath

            val photoUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                photoFile
            )

            val intent = Intent(MediaStore.ACTION_IMAGE_CAPTURE).apply {
                putExtra(MediaStore.EXTRA_OUTPUT, photoUri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            }

            if (intent.resolveActivity(packageManager) == null) {
                finishCameraWithError("camera_unavailable", "Nenhum app de camera encontrado.")
                return
            }

            startActivityForResult(intent, cameraRequestCode)
        } catch (error: Exception) {
            finishCameraWithError("camera_error", error.message ?: "Erro ao abrir a camera.")
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)

        if (requestCode != cameraRequestCode) return

        val result = pendingResult
        pendingResult = null

        if (resultCode == Activity.RESULT_OK) {
            result?.success(currentPhotoPath)
        } else {
            result?.success(null)
        }
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        if (requestCode != cameraPermissionRequestCode) return

        if (grantResults.firstOrNull() == PackageManager.PERMISSION_GRANTED) {
            openCamera()
        } else {
            finishCameraWithError("camera_permission_denied", "Permissao de camera negada.")
        }
    }

    private fun finishCameraWithError(code: String, message: String) {
        pendingResult?.error(code, message, null)
        pendingResult = null
    }
}
