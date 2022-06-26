$dllPath = Join-Path (Split-Path $myInvocation.MyCommand.path) "/../ICSharpCode.AvalonEdit.dll"
$assem = [Reflection.Assembly]::LoadFile($dllPath)  



$src = @'
using System;
using System.Windows;
using System.Windows.Input;
using System.Windows.Media.TextFormatting;
using System.Text.RegularExpressions;
using System.Collections.Generic;
using System.Diagnostics;
using System.ComponentModel;
using System.Drawing;
using ICSharpCode.AvalonEdit.Document;
using ICSharpCode.AvalonEdit.Folding;
using ICSharpCode.AvalonEdit.Rendering;


namespace AvalonEdit.Sample
{
    public class ThinktankDocument : INotifyPropertyChanged
    {
        private ICSharpCode.AvalonEdit.Document.TextDocument _Document = null;

        public ICSharpCode.AvalonEdit.Document.TextDocument Document
        {
            get { return _Document; }
            set { _Document = value; OnPropertyChanged("Document"); }
        }

        public event PropertyChangedEventHandler PropertyChanged;

        private void OnPropertyChanged(string name)
        {
            if (null == this.PropertyChanged) return;
            this.PropertyChanged(this, new PropertyChangedEventArgs(name));
        }
    }

	public class ThinktankFoldingStrategy
	{
		public void UpdateFoldings(FoldingManager manager, TextDocument document)
		{
			int firstErrorOffset;
			IEnumerable<NewFolding> newFoldings = CreateNewFoldings(document, out firstErrorOffset);
			manager.UpdateFoldings(newFoldings, firstErrorOffset);
		}
		
		public IEnumerable<NewFolding> CreateNewFoldings(TextDocument document, out int firstErrorOffset)
		{
			firstErrorOffset = -1;
			return CreateNewFoldings(document);
		}
		
		public IEnumerable<NewFolding> CreateNewFoldings(TextDocument document)
		{
			List<NewFolding> newFoldings = new List<NewFolding>();
			
            string[] section_start = { "^# .*", "^## .*",     "^### .*",    "^#### .*",   "^##### .*" };
            string[] section_end   = { "^# .*", "^#{1,2} .*", "^#{1,3} .*", "^#{1,4} .*", "^#{1,5} .*" };

            for( int j=0; j < section_start.Length; j++ ){
                var re_st = new Regex( section_start[j] );
                var re_en = new Regex( section_end[j] );
                int startLine = -1;
                int startOffset = -1;

                for (int i = 0; i < document.LineCount; i++ ){

                    if( i == document.LineCount - 1 ){
                        if( startLine != -1 ){
                            newFoldings.Add( new NewFolding( startOffset, document.GetOffset( i + 1, 0  ) ) );
                        }
                    }else{
                        bool currMatch = re_st.IsMatch( document.GetText( document.Lines[i].Offset,   document.Lines[i].Length   ) );
                        bool nextMatch = re_en.IsMatch( document.GetText( document.Lines[i+1].Offset, document.Lines[i+1].Length ) );
                        if( currMatch ){
                            if( nextMatch ){ 
                                startLine = -1;
                                startOffset = -1; 
                            }else{
                                startLine = i;
                                startOffset = document.Lines[i].EndOffset;
                            }
                        }else{
                            if( nextMatch && startLine != -1 ){ 
                                newFoldings.Add( new NewFolding( startOffset, document.GetOffset( i + 1, 0 ) ) );
                                startLine = -1;
                                startOffset = -1; 
                            }
                        }
                    }
                }
            }
            newFoldings.Sort( (a,b) => a.StartOffset.CompareTo( b.StartOffset ) );
			return newFoldings;
		}
	}
}

'@

Add-Type -TypeDefinition $src -ReferencedAssemblies $assem, PresentationFramework, PresentationCore, WindowsBase, System.Xaml

