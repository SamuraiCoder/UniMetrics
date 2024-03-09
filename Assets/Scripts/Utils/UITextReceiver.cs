using System;
using TMPro;
using UnityEngine;

namespace Utils
{
    public class UITextReceiver : MonoBehaviour
    {
        enum MetricType
        {
            CPU,
            RAM,
            GPU
        }


        [SerializeField] private MetricType metricType;
        [SerializeField] private TextMeshProUGUI label;

        private void Awake()
        {
            switch (metricType)
            {
                case MetricType.CPU:
                {
                    UniMetricsTracker.OnCPUReceive += OnMetricReceived;
                    break;
                }
                case MetricType.RAM:
                {
                    UniMetricsTracker.OnRAMReceive += OnMetricReceived;
                    break;
                }
                case MetricType.GPU:
                {
                    UniMetricsTracker.OnGPUReceive += OnMetricReceived;
                    break;
                }
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        private void OnDestroy()
        {
            UniMetricsTracker.OnCPUReceive -= OnMetricReceived;
            UniMetricsTracker.OnRAMReceive += OnMetricReceived;
            UniMetricsTracker.OnGPUReceive += OnMetricReceived;
        }

        private void OnMetricReceived(string receivedStr)
        {
            label.text = receivedStr;
        }
    }
}
