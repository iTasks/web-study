import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

public class ImageFilter {

    public static void main(String[] args) throws IOException {
        File inputFile = new File("path_to_input_image.jpg");
        BufferedImage image = ImageIO.read(inputFile);

        double[][] blurKernel = {
            { 0.0625, 0.125, 0.0625 },
            { 0.125, 0.25, 0.125 },
            { 0.0625, 0.125, 0.0625 }
        };

        BufferedImage filteredImage = applyFilter(image, blurKernel);
        File outputFile = new File("path_to_output_image.jpg");
        ImageIO.write(filteredImage, "jpg", outputFile);
    }

    public static BufferedImage applyFilter(BufferedImage srcImage, double[][] kernel) {
        int width = srcImage.getWidth();
        int height = srcImage.getHeight();
        BufferedImage dstImage = new BufferedImage(width, height, srcImage.getType());

        int kernelWidth = kernel.length;
        int kernelHeight = kernel[0].length;
        int kernelWidthOffset = kernelWidth / 2;
        int kernelHeightOffset = kernelHeight / 2;

        for (int y = 0; y < height; y++) {
            for (int x = 0; x < width; x++) {
                double red = 0.0, green = 0.0, blue = 0.0;

                for (int row = 0; row < kernelWidth; row++) {
                    for (int col = 0; col < kernelHeight; col++) {
                        int pixelX = (x - kernelWidthOffset + row + width) % width;
                        int pixelY = (y - kernelHeightOffset + col + height) % height;

                        int rgb = srcImage.getRGB(pixelX, pixelY);
                        double weight = kernel[row][col];

                        red += ((rgb >> 16) & 0xFF) * weight;
                        green += ((rgb >> 8) & 0xFF) * weight;
                        blue += (rgb & 0xFF) * weight;
                    }
                }

                int r = Math.min(Math.max((int)red, 0), 255);
                int g = Math.min(Math.max((int)green, 0), 255);
                int b = Math.min(Math.max((int)blue, 0), 255);

                dstImage.setRGB(x, y, (r << 16) | (g << 8) | b);
            }
        }

        return dstImage;
    }
}
