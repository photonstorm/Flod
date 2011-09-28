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

  public final class S2Instrument {
    internal var wave:int;
    internal var waveLength:int;
    internal var waveSpeed:int;
    internal var waveDelay:int;
    internal var arpeggio:int;
    internal var arpeggioLength:int;
    internal var arpeggioSpeed:int;
    internal var arpeggioDelay:int;
    internal var vibrato:int;
    internal var vibratoLength:int;
    internal var vibratoSpeed:int;
    internal var vibratoDelay:int;
    internal var pitchbend:int;
    internal var pitchbendDelay:int;
    internal var attackMax:int;
    internal var attackSpeed:int;
    internal var decayMin:int;
    internal var decaySpeed:int;
    internal var sustain:int;
    internal var releaseMin:int;
    internal var releaseSpeed:int;
  }
}