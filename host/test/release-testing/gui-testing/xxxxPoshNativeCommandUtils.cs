namespace xxxx
{
	using System.Text;
	public static class xxxxPoshNativeCommandUtils
	{
		/// <summary>
		/// Needs-Quotes Checking code corresponding to PoSh v5 
		/// (as adapted from an early Github version of NativeCommandParameterBinder.cs
		///  @ https://github.com/PowerShell/PowerShell/blob/60b3b304f2e1042bcf773d7e2ae3530a1f5d52f0/src/System.Management.Automation/engine/NativeCommandParameterBinder.cs
		/// )
		/// </summary>
		public static bool NeedQuotesPoshV5(string arg)
		{
			// bool needQuotes = false;
			int quoteCount = 0;
			for (int i = 0; i < arg.Length; i++)
			{
				if (arg[i] == '"')
				{
					quoteCount += 1;
				}
				else if (char.IsWhiteSpace(arg[i]) && (quoteCount % 2 == 0))
				{
					// needQuotes = true;
					return true;
				}
			}
			return false;
		}

		/// <summary>
		/// Needs-Quotes Checking code corresponding to PoSh v7.0
		/// (as adapted from the Github version of NeedQuotes(string stringToCheck) in NativeCommandParameterBinder.cs
		///  @ https://github.com/PowerShell/PowerShell/blame/bd6fdae73520931f0d27a29d6290e18761772141/src/System.Management.Automation/engine/NativeCommandParameterBinder.cs#L222
		/// )
		/// </summary>
		internal static bool NeedQuotesPoshV7(string arg)
		{
			bool followingBackslash = false;
			// bool needQuotes = false;
			int quoteCount = 0;
			for (int i = 0; i < arg.Length; i++)
			{
				if (arg[i] == '"' && !followingBackslash)
				{
					quoteCount += 1;
				}
				else if (char.IsWhiteSpace(arg[i]) && (quoteCount % 2 == 0))
				{
					// needQuotes = true;
					return true;
				}

				followingBackslash = arg[i] == '\\';
			}
			// return needQuotes;
			return false;
		}
	}
}
