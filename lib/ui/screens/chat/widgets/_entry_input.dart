part of '../wonders_chat_screen.dart';


/// Autopopulating textfield used for searching for Artifacts by name.
class _EntryInput extends StatefulWidget {
  const _EntryInput({Key? key, required this.onSubmit}) : super(key: key);
  final void Function(String) onSubmit;
  //final WonderData wonder;

  @override
  State<_EntryInput> createState() => _EntryInputState();
}

class _EntryInputState extends State<_EntryInput> {
  //File? _video;
  Uint8List? _thumbnailBytes;

  void _handleUploadTap() {
    appRouter.push(ScreenPaths.wonderDetails(WonderType.chichenItza));
  }

  Future<void> _handleGalleryTap_s3() async {
    final _picker = ImagePicker();
    final pickedFile = await _picker.pickVideo(
        source:  ImageSource.gallery
    );

    if (pickedFile != null) {
      // Get the file object from the picked file
      final file = File(pickedFile.path);

      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: pickedFile.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 512,
        quality: 50,
      );

      setState(() {
        //_video = File(pickedFile.path);
        _thumbnailBytes = thumbnailBytes;
      });


      // Upload the file to S3 bucket
      final fileName = path.basename(file.path);
      final key = 'uploads/$fileName';

      print("----start uploading------");
      print(key);

      /*
      Map<String, String> metadata = <String, String>{};
      metadata['name'] = "test1";
      metadata['desc'] = "";

      final options = S3UploadFileOptions(accessLevel: StorageAccessLevel.guest, metadata: metadata);
      final result = await Amplify.Storage.uploadFile(key: key, local: file, options: options);
      final uploadedFileUrl = await Amplify.Storage.getUrl(key: key);
      print(uploadedFileUrl);
       */
    }
  }

  Future<void> _handleCameraTap(context) async {
    print("--go to camera----");

    List<cam.CameraDescription> cameras = <cam.CameraDescription>[];

    // Fetch the available cameras before initializing the app.
    try {
      WidgetsFlutterBinding.ensureInitialized();
      cameras = await cam.availableCameras();
    } on cam.CameraException catch (e) {
      print("camera err------:");
      print(e.description);
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoRecorderHome(cameras: cameras)),
    );
  }

  Future<void> _handleGalleryTap(context) async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Get the file object from the picked file
      final thumbnailBytes = await VideoThumbnail.thumbnailData(
        video: pickedFile.path,
        imageFormat: ImageFormat.PNG,
        maxWidth: 512,
        quality: 50,
      );

      final image = Image.memory(
        thumbnailBytes!,
        fit: BoxFit.cover,
      );

      // Navigate to another screen and pass the selected image or video
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DisplayScreen(image: image)),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    Color captionColor = $styles.colors.caption;

    return Column(
      children: [

        Center(
          child: _thumbnailBytes == null
              ? Text('No video selected.')
              : Container(
            width: 256,
            height: 256,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white,
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 5.0,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.memory(
                _thumbnailBytes!,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        Gap($styles.insets.xs),

        Align(
          alignment: Alignment.bottomCenter,
          child: AppBtn.from(
                text: "select file",
                icon: Icons.login,
                expand: true,
                onPressed: () => _handleGalleryTap(context),
          ),
        ),

        Gap($styles.insets.xs),

        Align(
          alignment: Alignment.bottomCenter,
          child: AppBtn.from(
            text: "camera",
            icon: Icons.login,
            expand: true,
            onPressed: () => _handleCameraTap(context),
          ),
        )
      ],
    );
  }
}

class DisplayScreen extends StatelessWidget {
  final Image image;

  const DisplayScreen({Key? key, required this.image}) : super(key: key);

  Future<void> _handleUpload(context) async {
  }

    @override
  Widget build(BuildContext context) {
    Color captionColor = $styles.colors.caption;

    return Column(
      //crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SimpleHeader($strings.artifactsSearchTitleBrowse, subtitle: 'Upload'),
        Gap($styles.insets.xs),
        Container(
            padding: EdgeInsets.symmetric(horizontal: $styles.insets.sm),
            child: Container(
              //width: 256,
              height: 128,
              decoration: BoxDecoration(
                //shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 5.0,
                  ),
                ],
                image: DecorationImage(
                  image: image.image,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
            ),
        ),

        Gap($styles.insets.xs),

        Spacer(flex: 10),

        AppBtn.from(
          text: 'upload file',
          icon: Icons.login,
          expand: true,
          onPressed: () => _handleUpload(context),
        ),

      ],
    );
  }
}
