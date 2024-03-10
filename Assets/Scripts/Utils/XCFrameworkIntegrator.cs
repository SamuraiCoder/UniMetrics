#if UNITY_EDITOR
using System.IO;
using UnityEditor;
using UnityEditor.Callbacks;
using UnityEditor.iOS.Xcode;
using UnityEngine;

namespace Utils
{
    internal class XCFrameworkIntegrator
    {
        private const string FRAMEWORK_NAME = "UniMetricsSwift.xcframework";
    
        [PostProcessBuild]
        public static void OnPostprocessBuild(BuildTarget target, string pathToBuiltProject)
        {
            if (target != BuildTarget.iOS) return;

            // Define the path to the XCFramework within your Unity project
            string xcFrameworkRelativePath = $"Assets/Plugins/iOS/{FRAMEWORK_NAME}";
        
            // Define the destination path within the generated Xcode project
            string destFrameworkPath = Path.Combine(pathToBuiltProject, "Frameworks");
            string destXCFrameworkPath = Path.Combine(destFrameworkPath, FRAMEWORK_NAME);
        
            // Ensure the destination directory exists
            if (!Directory.Exists(destFrameworkPath))
            {
                Directory.CreateDirectory(destFrameworkPath);
            }
        
            // Copy the XCFramework from your Unity project to the Xcode project
            FileUtil.CopyFileOrDirectory(xcFrameworkRelativePath, destXCFrameworkPath);
        
            // Now, modify the Xcode project to include the XCFramework
            string projPath = PBXProject.GetPBXProjectPath(pathToBuiltProject);
            PBXProject proj = new PBXProject();
            proj.ReadFromString(File.ReadAllText(projPath));
        
            string targetGuid = proj.GetUnityMainTargetGuid();
        
            // Manually add the XCFramework reference to the project
            string fileGuid = proj.AddFile($"Frameworks/{FRAMEWORK_NAME}", $"Frameworks/{FRAMEWORK_NAME}");
        
            // Ensure the framework appears in the build phase
            proj.AddFileToBuild(targetGuid, fileGuid);
            
            File.WriteAllText(projPath, proj.WriteToString());
        
            Debug.Log("XCFramework integrated successfully into Xcode project.");
        }
    }
}
#endif
