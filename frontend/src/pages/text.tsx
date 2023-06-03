import { useCallback, useRef, useState } from 'preact/hooks'
import { convertImageDataToMonoHLSB } from '../utils/Utils'
import Api from '../utils/Api'

const WIDTH = 800
const HEIGHT = 480

const TextPage = () => {
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const [text, setText] = useState(``)

  const onChangeText = useCallback((event: Event) => {
    setText((event.target as HTMLInputElement).value)
  }, [])

  const onSubmit = useCallback(() => {
    if(canvasRef.current){
      const ctx = canvasRef.current.getContext("2d") as CanvasRenderingContext2D
      ctx.fillStyle = `white`
      ctx.fillRect(0, 0, WIDTH, HEIGHT)

      ctx.fillStyle = `black`
      ctx.font = "72px sans-serif"
      ctx.fillText(text, 10, 80)
      
      const rawImageData = ctx.getImageData(0, 0, WIDTH, HEIGHT).data
      const imageData = convertImageDataToMonoHLSB(rawImageData, WIDTH, HEIGHT)
      Api.postImageData(imageData)
    }
  }, [text])

  return (
    <>
      <h1>Text</h1>
      <input type="text" placeholder="Enter string..." value={text} onChange={onChangeText}></input>
      <button type="button" onClick={onSubmit}>SUBMIT</button>

      <canvas id="preview" width={WIDTH} height={HEIGHT} ref={canvasRef} style="border: 1px solid black;"></canvas>
    </>
  )
}

export default TextPage