module SFML.Graphics.Texture
(
    createTexture
,   textureFromFile
,   textureFromMemory
,   textureFromStream
,   textureFromImage
,   copyTexture
,   destroyTexture
,   textureSize
,   copyTextureToImage
,   updateTextureFromPixels
,   updateTextureFromImage
,   updateTextureFromWindow
,   updateTextureFromRenderWindow
,   bindTexture
,   setSmooth
,   isSmooth
,   setRepeated
,   isRepeated
,   textureMaxSize
)
where


import SFML.Graphics.Rect
import SFML.Graphics.Types
import SFML.Window.Types
import SFML.System.InputStream
import SFML.System.Vector2

import Foreign.C.String
import Foreign.C.Types
import Foreign.Marshal.Alloc (alloca)
import Foreign.Marshal.Utils (with)
import Foreign.Ptr
import Foreign.Storable (peek)
import System.IO.Unsafe
import Unsafe.Coerce (unsafeCoerce)


checkNull :: Texture -> Maybe Texture
checkNull tex@(Texture ptr) =
    case (unsafeCoerce ptr) of
        0 -> Nothing
        _ -> Just tex


-- | Create a new texture.
createTexture
    :: Int -- ^ Texture width
    -> Int -- ^ Texture height
    -> IO (Maybe Texture)

createTexture w h = fmap checkNull $ sfTexture_create (fromIntegral w) (fromIntegral h)

foreign import ccall unsafe "sfTexture_create"
    sfTexture_create :: CUInt -> CUInt -> IO Texture

--CSFML_GRAPHICS_API sfTexture* sfTexture_create(unsigned int width, unsigned int height);


-- | Create a new texture from a file.
textureFromFile
    :: FilePath -- ^ Path of the image file to load
    -> Maybe IntRect  -- ^ Area of the source image to load ('Nothing' to load the entire image)
    -> IO (Maybe Texture)

textureFromFile path rect =
    withCAString path $ \cpath ->
    fmap checkNull $
        case rect of
            Nothing -> sfTexture_createFromFile cpath nullPtr
            Just r  -> with r $ sfTexture_createFromFile cpath

foreign import ccall unsafe "sfTexture_createFromFile"
    sfTexture_createFromFile :: CString -> Ptr IntRect -> IO Texture

--CSFML_GRAPHICS_API sfTexture* sfTexture_createFromFile(const char* filename, const sfIntRect* area);


-- | Create a new texture from a file in memory.
textureFromMemory
    :: Ptr a   -- ^ Pointer to the file data in memory
    -> Int     -- ^ Size of the data to load, in bytes
    -> Maybe IntRect -- ^ Area of the source image to load ('Nothing' to load the entire image)
    -> IO (Maybe Texture)

textureFromMemory pixels size rect =
    fmap checkNull $ case rect of
        Nothing -> sfTexture_createFromMemory pixels (fromIntegral size) nullPtr
        Just r  -> with r $ sfTexture_createFromMemory pixels (fromIntegral size)

foreign import ccall unsafe "sfTexture_createFromMemory"
    sfTexture_createFromMemory :: Ptr a -> CUInt -> Ptr IntRect -> IO Texture

--CSFML_GRAPHICS_API sfTexture* sfTexture_createFromMemory(const void* data, size_t sizeInBytes, const sfIntRect* area);


-- | Create a new texture from a custom stream.
textureFromStream
    :: InputStream -- ^ Source stream to read from
    -> Maybe IntRect     -- ^ Area of the source image to load ('Nothing' to load the entire image)
    -> IO (Maybe Texture)

textureFromStream stream rect =
    fmap checkNull $
    with stream $ \streamPtr ->
    case rect of
        Nothing -> sfTexture_createFromStream streamPtr nullPtr
        Just r  -> with r $ sfTexture_createFromStream streamPtr

foreign import ccall "sfTexture_createFromStream"
     sfTexture_createFromStream :: Ptr InputStream -> Ptr IntRect -> IO Texture

--CSFML_GRAPHICS_API sfTexture* sfTexture_createFromStream(sfInputStream* stream, const sfIntRect* area);


-- | Create a new texture from an image.
textureFromImage
    :: Image   -- ^ Image to upload to the texture
    -> Maybe IntRect -- ^ Area of the source image to load ('Nothing' to load the entire image)
    -> IO (Maybe Texture)

textureFromImage image rect =
    fmap checkNull $ case rect of
        Nothing -> sfTexture_createFromImage image nullPtr
        Just r  -> with r $ sfTexture_createFromImage image

foreign import ccall unsafe "sfTexture_createFromImage"
    sfTexture_createFromImage :: Image -> Ptr IntRect -> IO Texture

--CSFML_GRAPHICS_API sfTexture* sfTexture_createFromImage(const sfImage* image, const sfIntRect* area);


-- | Copy an existing texture.
copyTexture :: Texture -> IO Texture
copyTexture = sfTexture_copy

foreign import ccall unsafe "sfTexture_copy"
    sfTexture_copy :: Texture -> IO Texture

--CSFML_GRAPHICS_API sfTexture* sfTexture_copy(sfTexture* texture);


-- | Destroy an existing texture.
destroyTexture :: Texture -> IO ()
destroyTexture = sfTexture_destroy

foreign import ccall unsafe "sfTexture_destroy"
    sfTexture_destroy :: Texture -> IO ()

--CSFML_GRAPHICS_API void sfTexture_destroy(sfTexture* texture);


-- | Return the size of the texture in pixels.
textureSize :: Texture -> IO Vec2u
textureSize tex = alloca $ \ptr -> sfTexture_getSize_helper tex ptr >> peek ptr

foreign import ccall unsafe "sfTexture_getSize_helper"
    sfTexture_getSize_helper :: Texture -> Ptr Vec2u -> IO ()

--CSFML_GRAPHICS_API sfVector2u sfTexture_getSize(const sfTexture* texture);


-- | Copy a texture's pixels to an image
copyTextureToImage :: Texture -> IO Image
copyTextureToImage = sfTexture_copyToImage

foreign import ccall unsafe "sfTexture_copyToImage"
    sfTexture_copyToImage :: Texture -> IO Image

--CSFML_GRAPHICS_API sfImage* sfTexture_copyToImage(const sfTexture* texture);


-- | Update a texture from an array of pixels.
updateTextureFromPixels
    :: Texture -- ^ Texture to update
    -> Ptr a   -- ^ Array of pixels to copy to the texture
    -> Int     -- ^ Width of the pixel region contained in \a pixels
    -> Int     -- ^ Height of the pixel region contained in \a pixels
    -> Int     -- ^ X offset in the texture where to copy the source pixels
    -> Int     -- ^ Y offset in the texture where to copy the source pixels
    -> IO ()

updateTextureFromPixels tex pixels w h x y =
    sfTexture_updateFromPixels tex pixels (fromIntegral w) (fromIntegral h) (fromIntegral x) (fromIntegral y)

foreign import ccall unsafe "sfTexture_updateFromPixels"
    sfTexture_updateFromPixels :: Texture -> Ptr a -> CUInt -> CUInt -> CUInt -> CUInt -> IO ()

--CSFML_GRAPHICS_API void sfTexture_updateFromPixels(sfTexture* texture, const sfUint8* pixels, unsigned int width, unsigned int height, unsigned int x, unsigned int y);


-- | Update a texture from an image.
updateTextureFromImage
    :: Texture -- ^ Texture to update
    -> Image   -- ^ Image to copy to the texture
    -> Int     -- ^ X offset in the texture where to copy the source pixels
    -> Int     -- ^ Y offset in the texture where to copy the source pixels
    -> IO ()

updateTextureFromImage tex image x y
    = sfTexture_updateFromImage tex image (fromIntegral x) (fromIntegral y)

foreign import ccall unsafe "sfTexture_updateFromImage"
    sfTexture_updateFromImage :: Texture -> Image -> CUInt -> CUInt -> IO ()

--CSFML_GRAPHICS_API void sfTexture_updateFromImage(sfTexture* texture, const sfImage* image, unsigned int x, unsigned int y);


-- | Update a texture from the contents of a window.
updateTextureFromWindow
    :: Texture -- ^ Texture to update
    -> Window  -- ^ Window to copy to the texture
    -> Int     -- ^ X offset in the texture where to copy the source pixels
    -> Int     -- ^ Y offset in the texture where to copy the source pixels
    -> IO ()

updateTextureFromWindow tex wnd x y
    = sfTexture_updateFromWindow tex wnd (fromIntegral x) (fromIntegral y)

foreign import ccall unsafe "sfTexture_updateFromWindow"
    sfTexture_updateFromWindow :: Texture -> Window -> CUInt -> CUInt -> IO ()

--CSFML_GRAPHICS_API void sfTexture_updateFromWindow(sfTexture* texture, const sfWindow* window, unsigned int x, unsigned int y);


-- | Update a texture from the contents of a render-window.
updateTextureFromRenderWindow
    :: Texture      -- ^ Texture to update
    -> RenderWindow -- ^ Render-window to copy to the texture
    -> Int          -- ^ X offset in the texture where to copy the source pixels
    -> Int          -- ^ Y offset in the texture where to copy the source pixels
    -> IO ()

updateTextureFromRenderWindow tex rwnd x y
    = sfTexture_updateFromRenderWindow tex rwnd (fromIntegral x) (fromIntegral y)

foreign import ccall unsafe "sfTexture_updateFromRenderWindow"
    sfTexture_updateFromRenderWindow :: Texture -> RenderWindow -> CUInt -> CUInt -> IO ()

--CSFML_GRAPHICS_API void sfTexture_updateFromRenderWindow(sfTexture* texture, const sfRenderWindow* renderWindow, unsigned int x, unsigned int y);


-- | Activate a texture for rendering.
bindTexture :: Texture -> IO ()
bindTexture = sfTexture_bind

foreign import ccall unsafe "sfTexture_bind"
    sfTexture_bind :: Texture -> IO ()

--CSFML_GRAPHICS_API void sfTexture_bind(const sfTexture* texture);


-- | Enable or disable the smooth filter on a texture.
setSmooth :: Texture -> Bool -> IO ()
setSmooth tex True  = sfTexture_setSmooth tex 1
setSmooth tex False = sfTexture_setSmooth tex 0

foreign import ccall unsafe "sfTexture_setSmooth"
    sfTexture_setSmooth :: Texture -> CInt -> IO ()

--CSFML_GRAPHICS_API void sfTexture_setSmooth(sfTexture* texture, sfBool smooth);


-- | Tell whether the smooth filter is enabled or not for a texture.
isSmooth :: Texture -> IO Bool
isSmooth = fmap (/=0) . sfTexture_isSmooth

foreign import ccall unsafe "sfTexture_isSmooth"
    sfTexture_isSmooth :: Texture -> IO CInt

--CSFML_GRAPHICS_API sfBool sfTexture_isSmooth(const sfTexture* texture);


-- | Enable or disable repeating for a texture.
--
-- Repeating is involved when using texture coordinates
-- outside the texture rectangle [0, 0, width, height].
-- In this case, if repeat mode is enabled, the whole texture
-- will be repeated as many times as needed to reach the
-- coordinate (for example, if the X texture coordinate is
-- 3 * width, the texture will be repeated 3 times).
-- If repeat mode is disabled, the "extra space" will instead
-- be filled with border pixels.
--
-- Warning: on very old graphics cards, white pixels may appear
-- when the texture is repeated. With such cards, repeat mode
-- can be used reliably only if the texture has power-of-two
-- dimensions (such as 256x128).
-- Repeating is disabled by default.
setRepeated :: Texture -> Bool -> IO ()
setRepeated tex True  = sfTexture_setRepeated tex 1
setRepeated tex False = sfTexture_setRepeated tex 0

foreign import ccall unsafe "sfTexture_setRepeated"
    sfTexture_setRepeated :: Texture -> CInt -> IO ()

--CSFML_GRAPHICS_API void sfTexture_setRepeated(sfTexture* texture, sfBool repeated);


-- | Tell whether a texture is repeated or not
isRepeated :: Texture -> IO Bool
isRepeated = fmap (/=0) . sfTexture_isRepeated

foreign import ccall unsafe "sfTexture_isRepeated"
    sfTexture_isRepeated :: Texture -> IO CInt

--CSFML_GRAPHICS_API sfBool sfTexture_isRepeated(const sfTexture* texture);


-- | The maximum texture size allowed in pixels.
textureMaxSize :: Int
textureMaxSize = unsafeDupablePerformIO $ fmap fromIntegral sfTexture_getMaximumSize

foreign import ccall unsafe "sfTexture_getMaximumSize"
    sfTexture_getMaximumSize :: IO CUInt

--CSFML_GRAPHICS_API unsigned int sfTexture_getMaximumSize();

