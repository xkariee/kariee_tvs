import { useState } from 'react'
import './style.scss'

const URL_INPUT: React.FC<{ back: (url: string, volume: number) => void }> = ({ back }) => {
    const [volume, setVolume] = useState<number>(50)
    const handleClick = () => {
        const url = document.querySelector('.url_input_i') as HTMLInputElement
        back(url.value, volume)

        url.value = ''
    }

    const handleClose = () => {
        back('', 0)
    }

    return (
        <div className="url_input">
            <div className="close" onClick={handleClose}><i className="fa-solid fa-xmark"></i></div>
            <div className="p">
                <div className="yt">
                    <span>Enter YT ID</span>
                    <input type="text" placeholder="ID (dQw4w9WgXcQ)" className="url_input_i" />
                </div>
                <div className="yt">
                    <span className="volume-text">Volume</span>
                    <div className="volume-container">
                        <span className="volume-icon"><i className="fa-solid fa-volume"></i></span>
                        <input type="range" className="volume-slider" min="0" max="100" id="volumeRange" value={volume} onInput={(e) => setVolume(parseInt(e.currentTarget.value))} style={{background: `linear-gradient(to right, #333 ${volume}%, #ddd ${volume}%)`}}/>
                        <span className="volume-percentage" id="volumePercentage">{volume}%</span>
                    </div>
                    <div className="btn" onClick={handleClick}>Confirm</div>
                </div>
            </div>
        </div>
    )
}

export default URL_INPUT