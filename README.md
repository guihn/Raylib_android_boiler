# Raylib Android Boilerplate Environment

This repository offers a ready-to-use environment for setting up Raylib on Android, streamlining the compilation, installation, and execution of Raylib-based applications on your Android device. Below are the prerequisites and steps required to get started.

## Prerequisites
- **Android NDK:** Ensure you have the Android Native Development Kit installed, you can install it following [the official documentation](https://developer.android.com/studio/projects/install-ndk).
- **raylib:** Compile Raylib for Android as a static library and place it in the project root. Refer to [this tutorial](https://github.com/raysan5/raylib/wiki/Working-for-Android-(on-Linux)) for detailed instructions.

## How to Run
1. **Modify Configuration:**
   - Update the package and app names in both `AndroidManifest.xml` and the `Makefile` to suit your preferences.
   
2. **Generate Keystore:**
   - Run the following command in your terminal to create a new fake keypair:
     ```bash
     make keystore
     ```
   
3. **Device Connection:**
   - Connect your Android device to the computer in debug mode.

4. **Compile, Install, and Run:**
   - Execute the following command in your terminal to compile the code, install the application on your device, and run it seamlessly:
     ```bash
     make clean all push run
     ```

## Credits and Acknowledgments
This project draws inspiration from [cnlohr/rawdrawandroid workflow](https://github.com/cnlohr/rawdrawandroid), modifying and adapting its Makefile and other elements to facilitate Raylib integration on the Android platform.

Feel free to contribute, modify, or enhance this boilerplate environment and share your improvements with the community!
