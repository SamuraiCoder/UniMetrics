#if UNITY_IOS
using System;
#if UNITY_IOS && !UNITY_EDITOR
using System.Globalization;
#endif
using System.Runtime.InteropServices;
using UnityEngine;

namespace Utils
{
    [Serializable]
    public class UniMetricsData 
    {
        public double cpuUsage; 
        public ulong ramUsage; // Plugin returns in MB
        public int gpuUsage;
        public string thermal;
    }
    
    public class UniMetricsTracker : MonoBehaviour
    {
        [DllImport("__Internal")]
        private static extern void startTracking();

        [DllImport("__Internal")]
        private static extern IntPtr stopTracking();

        public static event Action<string> OnCPUReceive;
        public static event Action<string> OnRAMReceive; 
        public static event Action<string> OnGPUReceive;
        public static event Action<string> OnThermalsReceive; 

        private void Awake()
        {
            UIEvents.OnStartClicked += StartTracking;
            UIEvents.OnStopClicked += StopTracking;
        }

        public void OnDestroy()
        {
            UIEvents.OnStartClicked -= StartTracking;
            UIEvents.OnStopClicked -= StopTracking;
        }

        private void StartTracking()
        {
#if UNITY_IOS && !UNITY_EDITOR
            startTracking();
#else
            Debug.LogWarning("UniMetrics does not work in Editor.");
#endif
        }

        private void StopTracking()
        {
#if UNITY_IOS && !UNITY_EDITOR
            IntPtr ptr = stopTracking();
            string result = Marshal.PtrToStringUTF8(ptr);

            UniMetricsData data = JsonUtility.FromJson<UniMetricsData>(result);

            OnCPUReceive?.Invoke(data.cpuUsage.ToString(CultureInfo.InvariantCulture));
            OnRAMReceive?.Invoke(data.ramUsage.ToString());
            OnGPUReceive?.Invoke(data.gpuUsage.ToString());
            OnThermalsReceive?.Invoke(data.thermal);
#else
            Debug.LogWarning("UniMetrics does not work in Editor.");
            
            //Send dummy data to the UI
            OnCPUReceive?.Invoke("6.2");
            OnRAMReceive?.Invoke("300");
            OnGPUReceive?.Invoke("18");
            OnThermalsReceive?.Invoke("Nominal");
#endif
        }
    }
}
#endif