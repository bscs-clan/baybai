import "package:flutter_test/flutter_test.dart";
import "package:tflite_flutter/tflite_flutter.dart";
import "dart:io";

void main() {
  test("inspect model output", () {
    final interpreter = Interpreter.fromFile(
      File("assets/models/baybai_ai_model.tflite"),
    );
    for (var tensor in interpreter.getInputTensors()) {
      print(
        "INPUT: \${tensor.name} type: \${tensor.type} shape: \${tensor.shape}",
      );
    }
  });
}
