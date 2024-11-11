import React, { useState, useEffect } from 'react';
import './CustomCursor.scss';

const CustomCursor:React.FC<{width: number, color: string}> = ({width, color}) => {
    const [position, setPosition] = useState({ x: 0, y: 0 });

    useEffect(() => {
        const moveCursor = (e: MouseEvent) => {
            setPosition({ x: e.clientX, y: e.clientY });
        };
        window.addEventListener('mousemove', moveCursor);
        return () => {
            window.removeEventListener('mousemove', moveCursor);
        };
    }, []);


    return (
        <div
            className="custom-cursor"
            style={{
                left: `${position.x}px`,
                top: `${position.y}px`,
                width: `${width}px`,
                height: `${width}px`,
                border: `2px solid ${color}`
            }}
        ></div>
    );
};

export default CustomCursor;
