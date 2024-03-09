using System;
using UnityEngine;

namespace Utils
{
    public class UIEvents : MonoBehaviour
    {
        public static event Action OnStartClicked;
        public static event Action OnStopClicked;
        
        public void OnStartClick()
        {
            OnStartClicked?.Invoke();
        }

        public void OnStopClick()
        {
            OnStopClicked?.Invoke();
        }
    }
}
