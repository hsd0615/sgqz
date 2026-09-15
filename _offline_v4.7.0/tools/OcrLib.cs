using System;
using System.Drawing;
using System.IO;
using System.Threading.Tasks;
using Windows.Graphics.Imaging;
using Windows.Media.Ocr;
using Windows.Storage.Streams;

public class OcrLib
{
    public static string ReadImage(string imagePath)
    {
        using (var bitmap = new Bitmap(imagePath))
        using (var ms = new MemoryStream())
        {
            bitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Bmp);
            ms.Seek(0, SeekOrigin.Begin);

            var randomStream = new MemoryRandomAccessStream(ms.ToArray());
            var decoder = BitmapDecoder.CreateAsync(randomStream).GetAwaiter().GetResult();
            var softwareBitmap = decoder.GetSoftwareBitmapAsync().GetAwaiter().GetResult();

            OcrEngine engine = null;
            var langs = OcrEngine.AvailableRecognizerLanguages;
            foreach (var lang in langs)
            {
                if (lang.LanguageTag.StartsWith("zh"))
                {
                    engine = OcrEngine.TryCreateFromLanguage(lang);
                    break;
                }
            }
            if (engine == null)
                engine = OcrEngine.TryCreateFromUserProfileLanguages();

            if (engine == null)
                return "[No OCR engine available. Install Chinese language pack in Windows Settings.]";

            var result = engine.RecognizeAsync(softwareBitmap).GetAwaiter().GetResult();
            var lines = new System.Text.StringBuilder();
            foreach (var line in result.Lines)
            {
                if (lines.Length > 0) lines.Append(Environment.NewLine);
                lines.Append(line.Text);
            }
            string text = lines.ToString();
            return string.IsNullOrEmpty(text) ? "(no text detected)" : text;
        }
    }
}

class MemoryRandomAccessStream : IRandomAccessStream
{
    private MemoryStream _ms;
    private ulong _size;

    public MemoryRandomAccessStream(byte[] data)
    {
        _ms = new MemoryStream(data);
        _size = (ulong)data.Length;
    }

    public bool CanRead { get { return true; } }
    public bool CanWrite { get { return false; } }
    public ulong Position { get { return (ulong)_ms.Position; } }
    public ulong Size { get { return _size; } set { _size = value; } }

    public IRandomAccessStream CloneStream()
    {
        var clone = new MemoryRandomAccessStream(_ms.ToArray());
        clone.Seek(this.Position);
        return clone;
    }

    public IInputStream GetInputStreamAt(ulong position)
    {
        var clone = new MemoryStream(_ms.ToArray());
        clone.Seek((long)position, SeekOrigin.Begin);
        return new InStream(clone);
    }

    public IOutputStream GetOutputStreamAt(ulong position)
    {
        throw new NotSupportedException();
    }

    public void Seek(ulong position)
    {
        _ms.Seek((long)position, SeekOrigin.Begin);
    }

    public void Dispose()
    {
        _ms.Dispose();
    }

    public Windows.Foundation.IAsyncOperationWithProgress<IBuffer, uint> ReadAsync(IBuffer buffer, uint count, InputStreamOptions options)
    {
        throw new NotImplementedException();
    }

    public Windows.Foundation.IAsyncOperationWithProgress<uint, uint> WriteAsync(IBuffer buffer)
    {
        throw new NotImplementedException();
    }

    public Windows.Foundation.IAsyncOperation<bool> FlushAsync()
    {
        throw new NotImplementedException();
    }
}

class InStream : IInputStream
{
    private Stream _stream;
    public InStream(Stream stream) { _stream = stream; }

    public Windows.Foundation.IAsyncOperationWithProgress<IBuffer, uint> ReadAsync(IBuffer buffer, uint count, InputStreamOptions options)
    {
        throw new NotImplementedException();
    }

    public void Dispose() { _stream.Dispose(); }
}
