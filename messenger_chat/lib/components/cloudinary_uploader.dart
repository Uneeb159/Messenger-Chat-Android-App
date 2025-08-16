import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:file_picker/file_picker.dart';

class CloudinaryUploader{
  final String cloudName = 'dj845hxmm';
  final String uploadPreset = 'fuse-chat';

  //pick image or file
  Future<String?> pickAndUploadImageorVideo() async{
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'mp4', 'mov', 'avi'],
    );

    if(result == null || result.files.isEmpty) return null;

    final file = File(result.files.first.path!);
    final fileExtension = file.path.split('.').last.toLowerCase();

    final isImage = ['jpg', 'jpeg', 'png'].contains(fileExtension);
    final isVideo = ['mp4', 'mov', 'avi'].contains(fileExtension);

    final resourceType = isImage ? 'image' : isVideo ? 'video' : null;
    if (resourceType == null) {
      print('Unsupported file type.');
      return null;
    }

    return await uploadToCloudinary(file, resourceType);
  }

  
  // Upload to Cloudinary
  Future<String?> uploadToCloudinary(File file, String resourceType) async{
    final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');
    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();

    if(response.statusCode == 200){
      final resStr = await response.stream.bytesToString();
      final resData = json.decode(resStr);
      return resData['secure_url'];
    }else{
      print('Cloudinary upload failes: ${response.statusCode}');
      return null;
    }
  }

}