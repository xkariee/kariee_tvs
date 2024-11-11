import React, { useEffect, useRef, useState } from 'react';
import './App.scss'
import { debugData } from "../utils/debugData";
import URL_INPUT from './comp/url_input';
import { fetchNui } from '../utils/fetchNui';


debugData([
  {
    action: 'setVisible',
    data: true,
  }
])

const App: React.FC = () => {

  function HandleURLTakeout(url: string, volume: number){
    if(url == ''){
      fetchNui('kariee_tvs:handleVolume', {volume: volume})
      fetchNui('closeUI').catch((error: Error) => { })
    } else {
      fetchNui('kariee_tvs:handleUrl', {url: url, volume: volume, width: 1920, height: 1080})
    }
  }

  useEffect(() => {
    const keyHandler = (e: KeyboardEvent) => {
      if (["Escape"].includes(e.code)) {
        fetchNui('closeUI').catch((error: Error) => { })
      }
    }

    window.addEventListener("keydown", keyHandler)

    return () => window.removeEventListener("keydown", keyHandler)
  }, [])

  return (
    <>
      <URL_INPUT back={HandleURLTakeout}/>
    </>
  )
}

export default App;