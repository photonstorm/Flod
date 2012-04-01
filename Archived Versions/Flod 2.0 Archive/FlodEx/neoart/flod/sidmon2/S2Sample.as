/* Flod SidMon2 Replay 1.0
   2009/12/17
   Christian Corti
   Neoart Costa Rica

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 	 OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 	 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR
 	 IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/

package neoart.flod.sidmon2 {
  import neoart.flod.amiga.*;

  public final class S2Sample extends AmigaSample {
    internal var negStart:int;
    internal var negLength:int;
    internal var negSpeed:int;
    internal var negDirection:int;
    internal var negOffset:int;
    internal var negStep:int;
    internal var negCounter:int;
    internal var negToggle:int;
  }
}