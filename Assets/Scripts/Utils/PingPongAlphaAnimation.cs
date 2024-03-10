using UnityEngine;
using UnityEngine.UI;

namespace Utils
{
    public class PingPongAlphaAnimation : MonoBehaviour
    {
        [SerializeField] private Image targetImage;
        [SerializeField] private float duration = 1f; 
        [SerializeField] private float minAlpha = 0f; 
        [SerializeField] private float maxAlpha = 1f; 
    
        private bool isAnimating;
        private float time;
        private float initialAlpha = 0.5f;

        private void Awake()
        {
            UIEvents.OnStartClicked += OnAnimationStarted;
            UIEvents.OnStopClicked += OnAnimationStopped;

        }

        private void OnAnimationStarted()
        {
            StartAnimation();
        }
        
        private void OnAnimationStopped()
        {
            StopAnimation();
        }

        private void OnDestroy()
        {
            UIEvents.OnStartClicked -= OnAnimationStarted;
            UIEvents.OnStopClicked -= OnAnimationStopped;

        }
        
        private void Update()
        {
            if (isAnimating)
            {
                // Ping-Pong the time value between 0 and duration
                time += Time.deltaTime;
                float lerpFactor = Mathf.PingPong(time, duration) / duration;
                float alpha = Mathf.Lerp(minAlpha, maxAlpha, lerpFactor);

                // Apply the calculated alpha to the image
                Color imageColor = targetImage.color;
                imageColor.a = alpha;
                targetImage.color = imageColor;
            }
        }

        private void StartAnimation()
        {
            isAnimating = true;
            time = 0f;
        }

        private void StopAnimation()
        {
            isAnimating = false;

            // Optional: reset the alpha to the maxAlpha or any other value if needed
            Color imageColor = targetImage.color;
            imageColor.a = initialAlpha;
            targetImage.color = imageColor;
        }
    }
}

