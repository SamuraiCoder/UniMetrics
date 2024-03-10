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
            GPU,
            THERMALS
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
                case MetricType.THERMALS:
                {
                    UniMetricsTracker.OnThermalsReceive += OnMetricReceived;
                    break;
                }
                default:
                    throw new ArgumentOutOfRangeException();
            }
        }

        private void OnDestroy()
        {
            UniMetricsTracker.OnCPUReceive -= OnMetricReceived;
            UniMetricsTracker.OnRAMReceive -= OnMetricReceived;
            UniMetricsTracker.OnGPUReceive -= OnMetricReceived;
            UniMetricsTracker.OnThermalsReceive -= OnMetricReceived;
        }

        private void OnMetricReceived(string receivedStr)
        {
            label.text = receivedStr;
        }
    }
}
