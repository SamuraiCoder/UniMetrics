#if UNITY_IOS
using System;
using System.Runtime.InteropServices;
using UnityEngine;

namespace Utils
{
    public class UniMetricsTracker : MonoBehaviour
    {
        [DllImport("__Internal")]
        private static extern void startTracking();

        [DllImport("__Internal")]
        private static extern IntPtr stopTracking();

        public static event Action<string> OnCPUReceive;
        public static event Action<string> OnRAMReceive; 
        public static event Action<string> OnGPUReceive; 

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
            startTracking();
        }

        private void StopTracking()
        {
            IntPtr ptr = stopTracking();
            string result = Marshal.PtrToStringAnsi(ptr);

            OnCPUReceive?.Invoke(result);
            OnRAMReceive?.Invoke(result);
            OnGPUReceive?.Invoke(result);
        }
    }
}
#endif