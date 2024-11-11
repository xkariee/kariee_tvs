import React, { useEffect, useState } from "react"
import './App.scss'

interface DUIVariables {
    action: string;
    imageSrc: string;
    width: number;
    height: number;
}

const TV: React.FC = () => {
    const [imageSrc, setImageSrc] = useState<string>("");
    const [dimensions, setDimensions] = useState<{ width: number; height: number }>({ width: 1920, height: 1080 });
    const [showing, setShowing] = useState<boolean>(false)
    const iframeRef = React.useRef<HTMLIFrameElement>(null);

    useEffect(() => {
        const handleMessage = (event: MessageEvent) => {
            if (event.data.action === "setDUIVariables") {
                const data: DUIVariables = event.data;

                setShowing(true)
                setImageSrc(data.imageSrc);
                setDimensions({ width: data.width, height: data.height });


            } else if (event.data.action == 'setDUIVolume'){
                if (event.data.volume && iframeRef.current) {
                    const iframeDoc = iframeRef.current.contentDocument || iframeRef.current.contentWindow?.document;
                    const mediaElement = iframeDoc?.querySelector<HTMLMediaElement>('audio, video');
                    
                    if (mediaElement) {
                        mediaElement.volume = event.data.volume / 100;
                    }
                }
            }
        };

        window.addEventListener("message", handleMessage);

        return () => {
            window.removeEventListener("message", handleMessage);
        };
    }, []);

    return (
        <>
            {showing &&
                <>
                    <iframe ref={iframeRef} width={dimensions.width} height={dimensions.height} src={`https://www.youtube.com/embed/${imageSrc}?autoplay=1`}></iframe>
                </>
            }
        </>
    );
}

export default TV